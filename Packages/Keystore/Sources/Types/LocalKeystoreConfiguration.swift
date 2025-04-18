// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct LocalKeystoreConfiguration: Sendable {
    public let folder: String
    public let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

    public init(folder: String = "keystore") {
        self.folder = folder
    }

    public var directory: URL {
        documentDirectory.appendingPathComponent(folder, isDirectory: true)
    }
}
