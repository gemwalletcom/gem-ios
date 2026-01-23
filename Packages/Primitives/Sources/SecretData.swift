// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public final class SecretData: @unchecked Sendable {
    private var storage: Data

    public init(_ data: Data) {
        self.storage = data
    }

    public init(string: String) {
        self.storage = Data(string.utf8)
    }

    public init(words: [String]) {
        self.storage = Data(words.joined(separator: " ").utf8)
    }

    public var string: String {
        String(data: storage, encoding: .utf8) ?? ""
    }

    public var words: [String] {
        string.split(separator: " ").map(String.init)
    }

    deinit {
        storage.zeroize()
    }
}

extension SecretData: Hashable {
    public static func == (lhs: SecretData, rhs: SecretData) -> Bool {
        lhs.storage == rhs.storage
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(storage)
    }
}
