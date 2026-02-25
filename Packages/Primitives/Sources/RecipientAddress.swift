// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct RecipientAddress: Hashable, Sendable {
    public let name: String
    public let address: String
    public let memo: String?

    public init(name: String, address: String, memo: String? = nil) {
        self.name = name
        self.address = address
        self.memo = memo
    }
}

extension RecipientAddress: Identifiable {
    public var id: String { String("\(name)\(address)") }
}
