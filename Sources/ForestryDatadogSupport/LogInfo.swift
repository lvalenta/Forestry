//
//  Copyright 2023 © Cleevio s.r.o. All rights reserved.
//

import Foundation
import ForestryLoggerLibrary

#if canImport(DatadogCore)
import DatadogCore
import DatadogInternal

typealias LogInfo = ForestryLoggerLibrary.LogInfo

extension LogInfo {
    var datadogAttributes: [AttributeKey: AttributeValue] {
        [
            DataDogAttributeKey.file.rawValue: file,
            DataDogAttributeKey.line.rawValue: line,
            DataDogAttributeKey.function.rawValue: function.description
        ]
    }
}

enum DataDogAttributeKey: String {
    case file
    case line
    case function
}
#endif
