// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct FileMigrator {
    private let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    public func migrate(
        name: String,
        fromDirectory: FileManager.SearchPathDirectory,
        toDirectory: FileManager.SearchPathDirectory,
        isDirectory: Bool
    ) throws -> URL {
        let directoryHint: URL.DirectoryHint = isDirectory ? .isDirectory : .notDirectory

        let oldURL = try fileManager.url(for: fromDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appending(path: name, directoryHint: directoryHint)
        let newURL = try fileManager.url(for: toDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appending(path: name, directoryHint: directoryHint)

        guard fileManager.fileExists(atPath: oldURL.path) else { return newURL }

        if !fileManager.fileExists(atPath: newURL.path) {
            try fileManager.moveItem(at: oldURL, to: newURL)
        }

        return newURL
    }
}
