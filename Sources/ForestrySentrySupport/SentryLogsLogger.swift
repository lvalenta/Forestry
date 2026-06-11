//
//  Copyright 2026 © Cleevio s.r.o. All rights reserved.
//

import Foundation
import ForestryLoggerLibrary
import Sentry

/// A logger that forwards all logs to Sentry Structured Logs (`SentrySDK.logger`).
///
/// This service does NOT start the SentrySDK. The SDK must be started with
/// `options.enableLogs = true` before any log is emitted — either by composing
/// a `SentryLogger` in the same `ForestryLogger`, or by using
/// `init(startingSDKWith:)`. If the SDK is not started, sentry-cocoa silently
/// drops the logs (no crash).
public final class SentryLogsLogger: LoggerService {
    public var minimalLogLevel: ForestryLoggerLibrary.LogLevel = .verbose

    /// UserInfo keys of type `.parameter`, attached to every log as attributes.
    /// Only mutated from ForestryLogger's internal actor, which serializes all calls.
    private var parameterUserInfo: [String: String] = [:]

    /// Testability seam: receives (level, body, attributes).
    internal var dispatch: (SentryLog.Level, String, [String: Any]) -> Void

    /// Use when SentrySDK.start is owned elsewhere (e.g. by a composed `SentryLogger`).
    public init() {
        self.dispatch = Self.sentrySDKDispatch
    }

    /// Starts the SDK (forcing `enableLogs = true`) unless it is already running.
    /// Use when `SentryLogsLogger` is the only Sentry service in the composition.
    public convenience init(startingSDKWith options: @autoclosure () -> Sentry.Options) {
        self.init()
        guard !SentrySDK.isEnabled else { return }
        let options = options()
        options.enableLogs = true
        SentrySDK.start(options: options)
    }

    public func log(info: LogInfo) {
        let attributes = Self.makeAttributes(info: info, userInfo: parameterUserInfo)
        dispatch(info.level.asSentryLogLevel, String(describing: info.message), attributes)
    }

    public func configureUserInfo(_ dictionary: [LogUserInfoKey: String]) {
        var tags: [String: String] = [:]
        for (key, value) in dictionary {
            switch key.type {
            case .parameter:
                parameterUserInfo[key.rawValue] = value
            case .tag:
                tags[key.rawValue] = value
            }
        }
        if !tags.isEmpty {
            SentrySDK.configureScope { scope in
                scope.setTags(tags)
            }
        }
    }

    public func removeUserInfo(_ keys: [LogUserInfoKey]) {
        for key in keys {
            switch key.type {
            case .parameter:
                parameterUserInfo[key.rawValue] = nil
            case .tag:
                SentrySDK.configureScope { scope in
                    scope.removeTag(key: key.rawValue)
                }
            }
        }
    }

    /// Builds per-log attributes. UserInfo never overrides the `code.*` keys.
    internal static func makeAttributes(info: LogInfo, userInfo: [String: String]) -> [String: Any] {
        var attributes: [String: Any] = userInfo
        attributes["code.file"] = info.file
        attributes["code.function"] = info.function
        attributes["code.line"] = info.line
        return attributes
    }

    private static func sentrySDKDispatch(level: SentryLog.Level, body: String, attributes: [String: Any]) {
        let logger = SentrySDK.logger
        switch level {
        case .trace:
            logger.trace(body, attributes: attributes)
        case .debug:
            logger.debug(body, attributes: attributes)
        case .info:
            logger.info(body, attributes: attributes)
        case .warn:
            logger.warn(body, attributes: attributes)
        case .error:
            logger.error(body, attributes: attributes)
        case .fatal:
            logger.fatal(body, attributes: attributes)
        @unknown default:
            logger.info(body, attributes: attributes)
        }
    }
}

internal extension ForestryLoggerLibrary.LogLevel {
    var asSentryLogLevel: SentryLog.Level {
        switch self {
        case .verbose:
            return .trace
        case .debug:
            return .debug
        case .info:
            return .info
        case .warning:
            return .warn
        case .error:
            return .error
        }
    }
}

public extension LoggerService where Self == SentryLogsLogger {
    /// A logger that forwards all logs to Sentry Structured Logs.
    /// SentrySDK must already be started with `enableLogs = true`.
    static var sentryLogs: SentryLogsLogger { .init() }
}
