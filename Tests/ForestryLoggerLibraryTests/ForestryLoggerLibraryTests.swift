//
//  Copyright 2023 © Cleevio s.r.o. All rights reserved.
//

import ForestryLoggerLibrary
import Testing

@Suite("ForestryLogger")
struct ForestryLoggerTests {
    let mockLoggerService: LoggerServiceMock
    let logger: ForestryLogger

    init() {
        let mock = LoggerServiceMock()
        self.mockLoggerService = mock
        self.logger = .init(service: mock)
    }

    @Test("log is delivered with the provided message")
    func log() async {
        let logMessage = "LogMessage"

        await confirmation("LogClosure is called") { confirmed in
            mockLoggerService.logClosure = { log in
                #expect(log.message as? String == logMessage)
                confirmed()
            }

            logger.info(logMessage)

            try? await Task.sleep(nanoseconds: 100_000_000)
        }
    }

    @Test("log is not delivered to services with a higher minimum level")
    func logIsNotCalledWithLowMinimumLevel() async {
        let logMessage = "LogMessage"

        let mock = LoggerServiceMock()
        mock.minimalLogLevel = .error

        await confirmation("Logger should not be called", expectedCount: 0) { confirmed in
            mock.logClosure = { _ in confirmed() }
            let logger = ForestryLogger(service: mock)

            logger.debug(logMessage)
            logger.verbose(logMessage)
            logger.info(logMessage)

            try? await Task.sleep(nanoseconds: 100_000_000)
        }
    }

    @Test("updateUserInfo forwards the full dictionary")
    func updateUserInfo() async {
        let expectedValue: [LogUserInfoKey: String] = [
            .userID: "11341",
            .deviceID: "147482",
            .custom(key: "PerfectKey"): "2422",
        ]

        await confirmation("UpdateUserInfo is called") { confirmed in
            mockLoggerService.configureUserInfoClosure = { userInfo in
                #expect(userInfo == expectedValue)
                confirmed()
            }

            logger.updateUserInfo(for: expectedValue)

            try? await Task.sleep(nanoseconds: 100_000_000)
        }
    }

    @Test("updateUserInfo with an empty dictionary still calls services")
    func updateUserInfoForEmptyDictionary() async {
        let expectedValue: [LogUserInfoKey: String] = [:]

        await confirmation("UpdateUserInfo is called") { confirmed in
            mockLoggerService.configureUserInfoClosure = { userInfo in
                #expect(userInfo == expectedValue)
                confirmed()
            }

            logger.updateUserInfo(for: expectedValue)

            try? await Task.sleep(nanoseconds: 100_000_000)
        }
    }

    @Test("updateUserInfo with a single key forwards a one-entry dictionary")
    func updateUserInfoSingleKey() async {
        let expectedKey = LogUserInfoKey.userID
        let expectedValue = "11341"

        await confirmation("UpdateUserInfo is called") { confirmed in
            mockLoggerService.configureUserInfoClosure = { userInfo in
                #expect(userInfo == [expectedKey: expectedValue])
                confirmed()
            }

            logger.updateUserInfo(for: expectedKey, with: expectedValue)

            try? await Task.sleep(nanoseconds: 100_000_000)
        }
    }

    @Test("removeUserInfo forwards the keys and reconfigures stored user info")
    func removeUserInfo() async {
        let expectedKeys: [LogUserInfoKey] = [.deviceID, .email, .custom(key: "Perfect key")]

        await confirmation("RemoveUserInfo and configureUserInfo are called", expectedCount: 2) { confirmed in
            mockLoggerService.removeUserInfoClosure = { keys in
                #expect(keys == expectedKeys)
                confirmed()
            }
            mockLoggerService.configureUserInfoClosure = { userInfo in
                #expect(userInfo == [:])
                confirmed()
            }

            logger.removeUserInfo(for: expectedKeys)

            try? await Task.sleep(nanoseconds: 100_000_000)
        }
    }

    @Test("removeUserInfo with empty keys still reconfigures stored user info")
    func removeUserInfoForEmptyKeys() async {
        let expectedKeys: [LogUserInfoKey] = []

        await confirmation("RemoveUserInfo and configureUserInfo are called", expectedCount: 2) { confirmed in
            mockLoggerService.removeUserInfoClosure = { keys in
                #expect(keys == expectedKeys)
                confirmed()
            }
            mockLoggerService.configureUserInfoClosure = { userInfo in
                #expect(userInfo == [:])
                confirmed()
            }

            logger.removeUserInfo(for: expectedKeys)

            try? await Task.sleep(nanoseconds: 100_000_000)
        }
    }

    @Test("removeUserInfo with a single key forwards the key")
    func removeUserInfoForSingleKey() async {
        let expectedKey = LogUserInfoKey.email

        await confirmation("RemoveUserInfo and configureUserInfo are called", expectedCount: 2) { confirmed in
            mockLoggerService.removeUserInfoClosure = { keys in
                #expect(keys == [expectedKey])
                confirmed()
            }
            mockLoggerService.configureUserInfoClosure = { userInfo in
                #expect(userInfo == [:])
                confirmed()
            }

            logger.removeUserInfo(for: expectedKey)

            try? await Task.sleep(nanoseconds: 100_000_000)
        }
    }

    @Test("removeUserInfo preserves previously set keys")
    func removeUserInfoPreservesPreviouslySetUserInfo() async {
        let dictionary: [LogUserInfoKey: String] = [
            .deviceID: "13131",
            .email: "lukas.valenta@cleevio.com",
            .custom(key: "Perfect key"): "42421",
        ]

        await confirmation("configureUserInfo is called twice", expectedCount: 2) { confirmed in
            nonisolated(unsafe) var configureCallCount = 0
            mockLoggerService.configureUserInfoClosure = { userInfo in
                if configureCallCount == 0 {
                    #expect(userInfo == dictionary)
                } else {
                    #expect(userInfo.count == 2)
                    #expect(userInfo[.deviceID] == "13131")
                    #expect(userInfo[.custom(key: "Perfect key")] == "42421")
                }
                configureCallCount += 1
                confirmed()
            }

            logger.updateUserInfo(for: dictionary)
            logger.removeUserInfo(for: .email)

            try? await Task.sleep(nanoseconds: 200_000_000)
        }
    }

    @Test("empty logger does not crash")
    func emptyLogger() async {
        let logger = ForestryLogger(services: [])

        logger.info("Message")
        logger.updateUserInfo(for: .email, with: "kgkfd")
        logger.removeUserInfo(for: .email)

        try? await Task.sleep(nanoseconds: 50_000_000)
    }
}
