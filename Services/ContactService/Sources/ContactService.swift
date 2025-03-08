// The Swift Programming Language
// https://docs.swift.org/swift-book

import Primitives
import Store
import GemAPI
import GRDBQuery
import SwiftUICore

public struct ContactService: Sendable {
    private let contactStore: ContactStore
    
    public init(contactStore: ContactStore) {
        self.contactStore = contactStore
    }
}

extension ContactService {
    public func add(contact: Contact) throws {
        try contactStore.addContact(record: contact.record)
    }
    
    public func add(address: ContactAddress) throws {
        try contactStore.addAddress(record: address.record)
    }
    
    public func edit(contact: Contact) throws {
        try contactStore.editContact(record: contact.record)
    }
    
    public func edit(address: ContactAddress) throws {
        try contactStore.editAddress(record: address.record)
    }
    
    public func delete(contact: Contact) throws -> Bool {
        return try contactStore.deleteContact(record: contact.record)
    }
    public func delete(address: ContactAddress) throws -> Bool {
        return try contactStore.deleteAddress(record: address.record)
    }
}
