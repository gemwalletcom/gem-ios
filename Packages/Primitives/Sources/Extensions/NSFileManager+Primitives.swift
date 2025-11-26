// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public extension FileManager {
    enum Directory: Sendable {
        case documents
        case applicationSupport
        case library(LibraryFolder)
        
        public enum LibraryFolder: String, Sendable {
            case preferences = "Preferences"
        }

        public var directory: String {
            switch self {
            case .documents: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            case .applicationSupport: NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)[0]
            case .library(let folder): NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0].appending(folder.rawValue)
            }
        }

        public var url: URL {
            URL(fileURLWithPath: directory)
        }
        
        public var name: String {
            switch self {
            case .documents: "Documents"
            case .applicationSupport: "Application Support"
            case .library(let folder): folder.rawValue
            }
        }
    }

    func addSkipBackupAttributeToItemAtURL(_ url: URL) throws {
        try (url as NSURL).setResourceValue(true, forKey: URLResourceKey.isExcludedFromBackupKey)
    }
}
