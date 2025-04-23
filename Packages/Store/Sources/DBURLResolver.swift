// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import OSLog

enum DBURLResolver {
    static func resolve(directory: String, fileName: String) throws -> URL {
        let fileManager = FileManager.default

        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documentDirectory.appending(path: fileName, directoryHint: .notDirectory)

        if fileManager.fileExists(atPath: url.path) {
            try fileManager.addSkipBackupAttributeToItemAtURL(documentDirectory)
            NSLog("DBURLResolver database url: \(url)")
            return url
        }

        let appSupportDirectory = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        let databaseDirectory = appSupportDirectory.appending(path: directory, directoryHint: .isDirectory)
        try fileManager.createDirectory(at: databaseDirectory, withIntermediateDirectories: true)
        try fileManager.addSkipBackupAttributeToItemAtURL(databaseDirectory)
        let databaseURL = databaseDirectory.appending(path: fileName, directoryHint: .notDirectory)

        NSLog("DBURLResolver database url: \(databaseURL)")

        return databaseURL
    }
}
