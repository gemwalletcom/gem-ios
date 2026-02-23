// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store

public struct ContactService: Sendable {
    private let store: ContactStore
    private let addressStore: AddressStore

    public init(store: ContactStore, addressStore: AddressStore) {
        self.store = store
        self.addressStore = addressStore
    }

    public func addContact(_ contact: Contact, addresses: [ContactAddress]) throws {
        try store.addContact(contact, addresses: addresses)
        try syncAddressNames(contact: contact, addresses: addresses)
    }

    public func updateContact(_ contact: Contact, addresses: [ContactAddress]) throws {
        let existingAddresses = try store.getAddresses(contactId: contact.id).asSet()
        let changes = SyncDiff.calculate(primary: .local, local: addresses.asSet(), remote: existingAddresses)

        try store.updateContact(contact, deleteAddressIds: changes.toDelete.map { $0.id }, addresses: addresses)
        try syncAddressNames(contact: contact, addresses: addresses)
        try deleteAddressNames(addresses: changes.toDelete.asArray())
    }

    public func deleteContact(id: String) throws {
        try store.deleteContact(id: id)
    }
}

// MARK: - Private

extension ContactService {
    private func syncAddressNames(contact: Contact, addresses: [ContactAddress]) throws {
        let addressNames = addresses.map {
            AddressName(chain: $0.chain, address: $0.address, name: contact.name)
        }
        try addressStore.addAddressNames(addressNames)
    }

    private func deleteAddressNames(addresses: [ContactAddress]) throws {
        for address in addresses {
            try addressStore.deleteAddress(chain: address.chain, address: address.address)
        }
    }
}
