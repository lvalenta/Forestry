//
//  Copyright 2023 © Cleevio s.r.o. All rights reserved.
//

import Foundation
import ForestryLoggerLibrary

final class LoggerServiceMock: LoggerService, @unchecked Sendable {
    var minimalLogLevel: LogLevel = .info
    var logClosure: ((LogInfo) -> Void)?
    var configureUserInfoClosure: (([LogUserInfoKey: String]) -> Void)?
    var removeUserInfoClosure: (([LogUserInfoKey]) -> Void)?
    
    func log(info: LogInfo) {
        logClosure?(info)
    }
    
    func configureUserInfo(_ dictionary: [LogUserInfoKey: String]) {
        configureUserInfoClosure?(dictionary)
    }
    
    func removeUserInfo(_ keys: [LogUserInfoKey]) {
        removeUserInfoClosure?(keys)
    }
}
