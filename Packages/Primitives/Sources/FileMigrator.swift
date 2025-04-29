// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum FileMigrator {
    public static func migrate(
        name: String,
        fromDirectory: FileManager.SearchPathDirectory,
        toDirectory: FileManager.SearchPathDirectory,
        isDirectory: Bool
    ) throws -> URL {
        let fileManager: FileManager = .default

        let oldURL = try fileManager.url(for: fromDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appending(path: name, directoryHint: isDirectory ? .isDirectory : .notDirectory)

        let newURL = try fileManager.url(for: toDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appending(path: name, directoryHint: isDirectory ? .isDirectory : .notDirectory)

        guard fileManager.fileExists(atPath: oldURL.path) else { return newURL }

        if !fileManager.fileExists(atPath: newURL.path) {
            try fileManager.moveItem(at: oldURL, to: newURL)
        }

        return newURL
    }
}
