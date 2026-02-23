// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct AddAddressInput: Sendable {
    public let chain: Chain
    public let address: String
    public let memo: String?
    public let name: String?

    public init(
        chain: Chain,
        address: String,
        memo: String? = nil,
        name: String? = nil
    ) {
        self.chain = chain
        self.address = address
        self.memo = memo
        self.name = name
    }
}
