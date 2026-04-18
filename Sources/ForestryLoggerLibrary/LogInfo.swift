//
//  Copyright 2023 © Cleevio s.r.o. All rights reserved.
//

import Foundation

/// A representation of individual log
public struct LogInfo {
    public var level: LogLevel
    public var line: Int
    public var function: StaticString
    public var file: String
    /// Raw message
    public var message: Any
    public var icon: String
    public var date = Date()

    /// Unified message format: `✅ AppDelegate:80 value(forKey:) > Raw message`
    public var formattedMessage: String {
        return "\(icon) \(file):\(line) \(function) > \(message)"
    }

    init(level: LogLevel, line: Int, function: StaticString, file: StaticString, message: Any, icon: String) {
        self.level = level
        self.line = line
        self.function = function
        self.file = Self.normalizeFileName(file: file)
        self.message = message
        self.icon = icon
    }

    private static func normalizeFileName(file: StaticString) -> String {
        // swiftlint:disable:next force_unwrapping
        file.description.components(separatedBy: "/").last!.replacingOccurrences(of: ".swift", with: "")
    }
}
