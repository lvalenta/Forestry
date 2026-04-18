//
//  Copyright 2023 © Cleevio s.r.o. All rights reserved.
//

@testable import ForestryLoggerLibrary
import Testing

@Suite("LogServiceRegistry")
struct LogServiceRegistryTests {

    private func makeService(_ level: LogLevel) -> LoggerServiceMock {
        let mock = LoggerServiceMock()
        mock.minimalLogLevel = level
        return mock
    }

    // MARK: - Empty

    @Test("empty registry has no services at any level")
    func emptyRegistryHasNoServicesAtAnyLevel() {
        let registry = LogServiceRegistry(services: [])

        #expect(registry.isEmpty)
        #expect(registry.allServices.isEmpty)
        for level in LogLevel.allCases {
            #expect(registry.services(for: level).isEmpty, "Expected no services for \(level)")
        }
    }

    // MARK: - Filtering semantics

    @Test("service qualifies for every level at or above its minimum")
    func serviceQualifiesForEveryLevelAtOrAboveItsMinimum() {
        let warningService = makeService(.warning)
        let registry = LogServiceRegistry(services: [warningService])

        #expect(registry.services(for: .verbose).isEmpty)
        #expect(registry.services(for: .debug).isEmpty)
        #expect(registry.services(for: .info).isEmpty)
        #expect(registry.services(for: .warning).count == 1)
        #expect(registry.services(for: .error).count == 1)
    }

    @Test("each level returns exactly the qualifying services")
    func eachLevelReturnsExactlyTheQualifyingServices() {
        let registry = LogServiceRegistry(services: [
            makeService(.error),
            makeService(.verbose),
            makeService(.info),
        ])

        #expect(registry.services(for: .verbose).map { $0.minimalLogLevel } == [.verbose])
        #expect(registry.services(for: .debug).map { $0.minimalLogLevel } == [.verbose])
        #expect(registry.services(for: .info).map { $0.minimalLogLevel } == [.verbose, .info])
        #expect(registry.services(for: .warning).map { $0.minimalLogLevel } == [.verbose, .info])
        #expect(registry.services(for: .error).map { $0.minimalLogLevel } == [.verbose, .info, .error])
    }

    // MARK: - Sorting

    @Test("services are sorted ascending by minimalLogLevel")
    func servicesAreSortedAscendingByMinimalLogLevel() {
        let services = [
            makeService(.error),
            makeService(.verbose),
            makeService(.warning),
            makeService(.debug),
            makeService(.info),
        ]

        let registry = LogServiceRegistry(services: services)

        #expect(registry.allServices.map { $0.minimalLogLevel } == [.verbose, .debug, .info, .warning, .error])
    }

    @Test("duplicate log levels are preserved")
    func duplicateLogLevelsArePreserved() {
        let registry = LogServiceRegistry(services: [
            makeService(.info),
            makeService(.info),
            makeService(.info),
        ])

        #expect(registry.allServices.count == 3)
        #expect(registry.services(for: .debug).count == 0)
        #expect(registry.services(for: .info).count == 3)
        #expect(registry.services(for: .error).count == 3)
    }

    // MARK: - All levels / boundaries

    @Test("service at verbose minimum is returned for every level")
    func serviceAtVerboseMinimumIsReturnedForEveryLevel() {
        let registry = LogServiceRegistry(services: [makeService(.verbose)])

        for level in LogLevel.allCases {
            #expect(registry.services(for: level).count == 1, "Expected verbose service at \(level)")
        }
    }

    @Test("service at error minimum is only returned for error")
    func serviceAtErrorMinimumIsOnlyReturnedForError() {
        let registry = LogServiceRegistry(services: [makeService(.error)])

        #expect(registry.services(for: .verbose).isEmpty)
        #expect(registry.services(for: .debug).isEmpty)
        #expect(registry.services(for: .info).isEmpty)
        #expect(registry.services(for: .warning).isEmpty)
        #expect(registry.services(for: .error).count == 1)
    }

    // MARK: - Lookup performs no filtering

    @Test("hasAnyService reports presence per level")
    func hasAnyServiceReportsPresencePerLevel() {
        let registry = LogServiceRegistry(services: [makeService(.info)])

        #expect(!registry.hasAnyService(for: .verbose))
        #expect(!registry.hasAnyService(for: .debug))
        #expect(registry.hasAnyService(for: .info))
        #expect(registry.hasAnyService(for: .warning))
        #expect(registry.hasAnyService(for: .error))
    }

    @Test("hasAnyService is false for an empty registry")
    func hasAnyServiceIsFalseForEmptyRegistry() {
        let registry = LogServiceRegistry(services: [])

        for level in LogLevel.allCases {
            #expect(!registry.hasAnyService(for: level))
        }
    }

    @Test("returned slice references all services storage")
    func returnedSliceReferencesAllServicesStorage() {
        let services = [makeService(.verbose), makeService(.info), makeService(.error)]
        let registry = LogServiceRegistry(services: services)

        let slice = registry.services(for: .error)
        #expect(slice.count == registry.allServices.count)
        #expect(slice.startIndex == registry.allServices.startIndex)
        #expect(slice.endIndex == registry.allServices.endIndex)
    }
}
