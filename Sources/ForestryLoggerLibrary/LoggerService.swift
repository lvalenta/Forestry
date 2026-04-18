//
//  Copyright 2023 © Cleevio s.r.o. All rights reserved.
//

import Foundation

public protocol LoggerService {
    /// A minimal log level that this service should be used for.
    ///
    /// This value is read once when the service is passed to `ForestryLogger`
    /// and is cached in a precomputed routing table for fast lookup.
    /// Mutating it afterwards has no effect on log routing.
    var minimalLogLevel: LogLevel { get }

    /// Logs the message in services based on minimumLogLevel.
    /// The log may be executed from a different Thread than the one that called the function as the logging happens asynchronously.
    func log(info: LogInfo)
    
    /// Updates user info values for provided keys in each logging service.
    /// It is not necessary to call it with previously set key value pairs.
    func configureUserInfo(_ dictionary: [LogUserInfoKey: String])
    
    /// Removes previously set userinfo for provided keys in each logging service
    func removeUserInfo(_ keys: [LogUserInfoKey])
}

extension LoggerService {
    @inlinable
    public func configureUserInfo(_ dictionary: [LogUserInfoKey : String]) {
        
    }
    
    @inlinable
    public func removeUserInfo(_ keys: [LogUserInfoKey]) {
        
    }
}
