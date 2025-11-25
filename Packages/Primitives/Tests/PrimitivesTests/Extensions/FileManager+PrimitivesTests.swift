// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import Foundation

struct FileManager_PrimitivesTests {
    @Test
    func excludedBackupDirectories() {
        let directories = FileManager.default.excludedBackupDirectories

        #expect(directories.count == 3)
        #expect(directories.contains(.documents))
        #expect(directories.contains(.applicationSupport))
        #expect(directories.contains(.preferences))
    }
}
