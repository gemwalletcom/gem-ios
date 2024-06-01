// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public extension FileManager {
    func addSkipBackupAttributeToItemAtURL(_ url: URL) throws {
        try (url as NSURL).setResourceValue(true, forKey: URLResourceKey.isExcludedFromBackupKey)
    }
}
