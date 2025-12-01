// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import Foundation

struct FileManager_PrimitivesTests {

    enum DirectoryTestCase: CaseIterable {
        case documents
        case applicationSupport
        case libraryPreferences

        var directory: FileManager.Directory {
            switch self {
            case .documents: .documents
            case .applicationSupport: .applicationSupport
            case .libraryPreferences: .library(.preferences)
            }
        }

        var expectedPath: String {
            switch self {
            case .documents: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            case .applicationSupport: NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)[0]
            case .libraryPreferences: NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0] + "/Preferences"
            }
        }
    }

    @Test(arguments: DirectoryTestCase.allCases)
    func directoryPath(testCase: DirectoryTestCase) {
        #expect(testCase.directory.directory == testCase.expectedPath)
    }
}
