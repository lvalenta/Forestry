//
//  Copyright 2023 © Cleevio s.r.o. All rights reserved.
//

import Foundation
import ForestryLoggerLibrary
import Sentry

/// A logger that sends error logs to the Sentry
public struct SentryLogger: LoggerService {
    public typealias Options = Sentry.Options
    
    public var minimalLogLevel: ForestryLoggerLibrary.LogLevel = .error

    public init(options: @autoclosure () -> Options) {
        SentrySDK.start(options: options())
    }

    public func log(info: LogInfo) {
        let event = Event()
        event.message = SentryMessage(formatted: info.formattedMessage)
        event.level = info.level.asSentryLevel
        event.fingerprint = [info.file, info.function.description, String(info.line)]
        SentrySDK.capture(event: event)
    }

    public func configureUserInfo(_ dictionary: [LogUserInfoKey : String]) {
        SentrySDK.configureScope { scope in
            scope.setTags(dictionary.stringKeyedDictionary)
        }
    }
}

private extension LogLevel {
    var asSentryLevel: SentryLevel {
        switch self {
        case .verbose:
            return .none
        case .debug:
            return .debug
        case .info:
            return .info
        case .warning:
            return .warning
        case .error:
            return .error
        }
    }
}


public extension LoggerService where Self == SentryLogger {
    /// A logger that sends error logs to the Sentry
    @inlinable
    static func sentry(options: @autoclosure () -> SentryLogger.Options) -> SentryLogger {
        .init(options: options())
    }
    
}
