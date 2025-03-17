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
    public func add(contact: Contact) throws -> ContactId {
        return try contactStore.addContact(contact)
    }
    
    public func add(address: ContactAddress) throws {
        try contactStore.addAddress(address)
    }
    
    public func edit(contact: Contact) throws {
        try contactStore.editContact(contact)
    }
    
    public func edit(address: ContactAddress) throws {
        try contactStore.editAddress(address)
    }
    
    public func delete(contact: Contact) throws -> Bool {
        return try contactStore.deleteContact(contact)
    }
    
    public func delete(address: ContactAddress) throws -> Bool {
        return try contactStore.deleteAddress(address)
    }
}
