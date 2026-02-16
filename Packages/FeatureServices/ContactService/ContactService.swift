// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store

public struct ContactService: Sendable {
    private let store: ContactStore

    public init(store: ContactStore) {
        self.store = store
    }

    public func addContact(_ contact: Contact) throws {
        try store.addContact(contact)
    }

    public func updateContact(_ contact: Contact) throws {
        try store.updateContact(contact)
    }

    public func deleteContact(id: String) throws {
        try store.deleteContact(id: id)
    }
}
