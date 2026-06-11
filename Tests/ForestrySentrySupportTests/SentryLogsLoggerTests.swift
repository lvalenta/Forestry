//
//  Copyright 2026 © Cleevio s.r.o. All rights reserved.
//

import Foundation
@testable import ForestryLoggerLibrary
@testable import ForestrySentrySupport
import Sentry
import XCTest

final class SentryLogsLoggerTests: XCTestCase {
    private var logger: SentryLogsLogger!
    private var dispatched: [(level: SentryLog.Level, body: String, attributes: [String: Any])] = []

    override func setUp() {
        super.setUp()

        logger = SentryLogsLogger()
        dispatched = []
        logger.dispatch = { [weak self] level, body, attributes in
            self?.dispatched.append((level, body, attributes))
        }
    }

    private func makeLogInfo(
        level: LogLevel = .info,
        message: Any = "Message",
        file: String = "/Some/Path/AppDelegate.swift",
        function: String = "application(_:didFinishLaunchingWithOptions:)",
        line: Int = 42
    ) -> LogInfo {
        LogInfo(level: level, line: line, function: function, file: file, message: message, icon: "ℹ️")
    }

    // MARK: - Level mapping

    func testLevelMapping() {
        XCTAssertEqual(LogLevel.verbose.asSentryLogLevel, .trace)
        XCTAssertEqual(LogLevel.debug.asSentryLogLevel, .debug)
        XCTAssertEqual(LogLevel.info.asSentryLogLevel, .info)
        XCTAssertEqual(LogLevel.warning.asSentryLogLevel, .warn)
        XCTAssertEqual(LogLevel.error.asSentryLogLevel, .error)
    }

    func testLogDispatchesMappedLevel() {
        logger.log(info: makeLogInfo(level: .warning))

        XCTAssertEqual(dispatched.count, 1)
        XCTAssertEqual(dispatched.first?.level, .warn)
    }

    // MARK: - Body

    func testBodyIsVerbatimMessageWithoutFormattingPrefix() {
        logger.log(info: makeLogInfo(message: "Raw message"))

        XCTAssertEqual(dispatched.first?.body, "Raw message")
    }

    // MARK: - Attributes

    func testCodeAttributes() {
        logger.log(info: makeLogInfo())

        let attributes = dispatched.first?.attributes
        // LogInfo normalizes the file name (path and .swift extension stripped)
        XCTAssertEqual(attributes?["code.file"] as? String, "AppDelegate")
        XCTAssertEqual(attributes?["code.function"] as? String, "application(_:didFinishLaunchingWithOptions:)")
        XCTAssertEqual(attributes?["code.line"] as? Int, 42)
    }

    func testParameterUserInfoIsAttachedAsAttributes() {
        logger.configureUserInfo([.userID: "user-123", .sceneIdentifier: "scene-1"])
        logger.log(info: makeLogInfo())

        let attributes = dispatched.first?.attributes
        XCTAssertEqual(attributes?["userID"] as? String, "user-123")
        XCTAssertEqual(attributes?["sceneIdentifier"] as? String, "scene-1")
    }

    func testUserInfoCannotOverrideCodeAttributes() {
        let attributes = SentryLogsLogger.makeAttributes(
            info: makeLogInfo(),
            userInfo: ["code.file": "Spoofed", "custom": "value"]
        )

        XCTAssertEqual(attributes["code.file"] as? String, "AppDelegate")
        XCTAssertEqual(attributes["custom"] as? String, "value")
    }

    func testRemoveUserInfoRemovesParameterKeys() {
        logger.configureUserInfo([.userID: "user-123"])
        logger.removeUserInfo([.userID])
        logger.log(info: makeLogInfo())

        XCTAssertNil(dispatched.first?.attributes["userID"])
    }

    // MARK: - Defaults

    func testDefaultMinimalLogLevelIsVerbose() {
        XCTAssertEqual(SentryLogsLogger().minimalLogLevel, .verbose)
    }
}
