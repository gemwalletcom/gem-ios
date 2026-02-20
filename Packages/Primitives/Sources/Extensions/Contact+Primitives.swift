// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public extension ContactAddress {
    static func new(
        contactId: String,
        chain: Chain,
        address: String,
        memo: String?
    ) -> ContactAddress {
        ContactAddress(
            id: chain.rawValue + "_" + address,
            contactId: contactId,
            address: address,
            chain: chain,
            memo: memo
        )
    }
}
