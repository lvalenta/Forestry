//
//  Copyright 2026 © Cleevio s.r.o. All rights reserved.
//

import Foundation
import Sentry

/// Sets the Sentry scope user so that logs, events and replays are filterable per user,
/// without the host app having to link Sentry directly.
public enum SentryUserIdentity {
    /// Sets the current Sentry user. Passing a nil `id` clears the user (e.g. on logout).
    public static func set(id: String?, email: String? = nil, username: String? = nil) {
        guard let id else {
            SentrySDK.setUser(nil)
            return
        }
        let user = User(userId: id)
        user.email = email
        user.username = username
        SentrySDK.setUser(user)
    }
}
