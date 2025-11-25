// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public extension FileManager {
    enum Directory: String {
        case documents
        case applicationSupport
        case preferences

        public var directory: String {
            switch self {
            case .documents: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            case .applicationSupport: NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)[0]
            case .preferences: NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0].appending("/Preferences")
            }
        }

        public var url: URL {
            URL(fileURLWithPath: directory)
        }
    }
    
    var excludedBackupDirectories: [Directory] {
        [.documents, .applicationSupport, .preferences]
    }

    func addSkipBackupAttributeToItemAtURL(_ url: URL) throws {
        try (url as NSURL).setResourceValue(true, forKey: URLResourceKey.isExcludedFromBackupKey)
    }
}
