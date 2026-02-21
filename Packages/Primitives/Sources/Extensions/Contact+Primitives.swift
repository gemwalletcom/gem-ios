// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public extension Contact {
    static func new(
        id: String,
        name: String,
        description: String?,
        createdAt: Date = .now
    ) -> Contact {
        Contact(
            id: id,
            name: name,
            description: description,
            createdAt: createdAt,
            updatedAt: .now
        )
    }
}

public extension ContactAddress {
    static func new(
        contactId: String,
        chain: Chain,
        address: String,
        memo: String?
    ) -> ContactAddress {
        ContactAddress(
            id: contactId + "_"  + chain.rawValue + "_" + address,
            contactId: contactId,
            address: address,
            chain: chain,
            memo: memo
        )
    }
}
