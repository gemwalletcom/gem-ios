// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension Contact {
    static func mock(
        id: String = "contact-1",
        name: String = "John Doe",
        description: String? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) -> Contact {
        Contact(id: id, name: name, description: description, createdAt: createdAt, updatedAt: updatedAt)
    }
}

public extension ContactAddress {
    static func mock(
        id: String = "address-1",
        contactId: String = "contact-1",
        address: String = "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh",
        chain: Chain = .bitcoin,
        memo: String? = nil
    ) -> ContactAddress {
        ContactAddress(
            id: id,
            contactId: contactId,
            address: address,
            chain: chain,
            memo: memo
        )
    }
}

public extension ContactData {
    static func mock(
        contact: Contact = .mock(),
        addresses: [ContactAddress] = [.mock()]
    ) -> ContactData {
        ContactData(contact: contact, addresses: addresses)
    }
}
