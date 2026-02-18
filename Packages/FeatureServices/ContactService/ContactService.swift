// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store

public struct ContactService: Sendable {
    private let store: ContactStore

    public init(store: ContactStore) {
        self.store = store
    }

    public func saveContact(_ contact: Contact, addresses: [ContactAddress]) throws {
        try store.saveContact(contact, addresses: addresses)
    }

    public func deleteContact(id: String) throws {
        try store.deleteContact(id: id)
    }
}
