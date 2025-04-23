// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
@testable import Store

struct DBURLResolverTests {
    private let fileName = "db.sqlite"
    private let directory = "DatabaseMock"
    private let fileManager: FileManager = .default

    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private var legacyURL: URL {
        documentsDirectory.appending(path: fileName)
    }

    private var applicationSupportDirURL: URL {
        try! applicationSupportDatabaseDirectory()
    }

    @Test
    func testLegacyPath() throws {
        try clean(legacyURL)
        try clean(applicationSupportDirURL)

        fileManager.createFile(atPath: legacyURL.path(percentEncoded: false), contents: Data())

        let resolved = try DBURLResolver.resolve(
            directory: directory,
            fileName: fileName
        )

        #expect(resolved == legacyURL)
        #expect(fileManager.fileExists(atPath: resolved.path(percentEncoded: false)))
    }

    @Test
    func testNewPath() throws {
        try clean(legacyURL)
        try clean(applicationSupportDirURL)

        let resolved = try DBURLResolver.resolve(
            directory: directory,
            fileName: fileName
        )

        #expect(resolved.path(percentEncoded: false).contains("/Application Support/\(directory)/"))

        var isDirectoryFlag: ObjCBool = false
        #expect(
            fileManager.fileExists(
                atPath: applicationSupportDirURL.path(percentEncoded: false),
                isDirectory: &isDirectoryFlag
            )
        )
        #expect(isDirectoryFlag.boolValue == true)
    }

    private func clean(_ url: URL) throws {
        if fileManager.fileExists(atPath: url.path(percentEncoded: false)) {
            try fileManager.removeItem(at: url)
        }
    }

    private func applicationSupportDatabaseDirectory() throws -> URL {
        let applicationSupportDirectory = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return applicationSupportDirectory.appending(path: "\(directory)", directoryHint: .isDirectory)
    }
}
