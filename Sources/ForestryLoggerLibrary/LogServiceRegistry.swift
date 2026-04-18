//
//  Copyright 2023 © Cleevio s.r.o. All rights reserved.
//

import Foundation

/// A precomputed routing table for logger services.
///
/// Services are sorted ascending by `minimalLogLevel` at initialization.
/// For every `LogLevel`, an exclusive upper-bound index into the sorted array
/// is stored so that `services(for:)` is O(1) and returns a non-allocating
/// `ArraySlice` of the services that should receive a log at that level.
struct LogServiceRegistry {
    let sortedServices: [LoggerService]
    let endIndexByLevel: [LogLevel: Int]

    var isEmpty: Bool { sortedServices.isEmpty }
    var allServices: [LoggerService] { sortedServices }

    init(services: [LoggerService]) {
        let sorted = services.sorted { $0.minimalLogLevel < $1.minimalLogLevel }
        var indices: [LogLevel: Int] = [:]
        let logLevelCases = LogLevel.allCases
        indices.reserveCapacity(logLevelCases.count)
        for level in logLevelCases {
            indices[level] = sorted.firstIndex { $0.minimalLogLevel > level } ?? services.count
        }
        self.sortedServices = sorted
        self.endIndexByLevel = indices
    }

    /// Services whose `minimalLogLevel` is less than or equal to `level`.
    func services(for level: LogLevel) -> ArraySlice<LoggerService> {
        let endIndex = endIndexByLevel[level, default: 0]
        return sortedServices[..<endIndex]
    }

    func hasAnyService(for level: LogLevel) -> Bool {
        endIndexByLevel[level, default: 0] > 0
    }
}
