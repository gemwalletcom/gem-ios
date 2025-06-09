// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct RecipientAddress: Hashable, Sendable {
    public let name: String
    public let address: String

    public init(name: String, address: String) {
        self.name = name
        self.address = address
    }
}

extension RecipientAddress: Identifiable {
    public var id: String { String("\(name)\(address)") }
}
