//
//  Copyright 2023 © Cleevio s.r.o. All rights reserved.
//

import Foundation
import SwiftyBeaver
import ForestryLoggerLibrary

/// A logger that sends all logs to the Swift Beaver cloud.
public struct SwiftyBeaverLogger: LoggerService {

    private let logger = SwiftyBeaver.self
    private let cloudLogger: SBPlatformDestination

    public var minimalLogLevel: ForestryLoggerLibrary.LogLevel = .verbose

    public init(cloudLogger: SBPlatformDestination) {
        self.cloudLogger = cloudLogger
        logger.addDestination(cloudLogger)
    }

    public func log(info: LogInfo) {
        logger.custom(
            level: info.level.asSwiftyBeaverLevel,
            message: info.message,
            file: info.file,
            function: info.function.description,
            line: info.line
        )
    }

    // TODO: Handle user info
    public func configureUserInfo(_ dictionary: [LogUserInfoKey : String]) { }
}

extension LogLevel {
    var asSwiftyBeaverLevel: SwiftyBeaver.Level {
        switch self {
        case .verbose:
            return .verbose
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

public extension LoggerService where Self == SwiftyBeaverLogger {
    /// A logger that sends all logs to the Swift Beaver cloud.
    @inlinable
    static func swiftyBeaver(cloudLogger: SBPlatformDestination) -> SwiftyBeaverLogger {
        .init(cloudLogger: cloudLogger)
    }
}
