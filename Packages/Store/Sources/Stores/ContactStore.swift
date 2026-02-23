// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct ContactStore: Sendable {

    let db: DatabaseQueue

    public init(db: DB) {
        self.db = db.dbQueue
    }

    public func addContact(_ contact: Contact, addresses: [ContactAddress]) throws {
        try db.write { db in
            try contact.record.insert(db)
            for address in addresses {
                try address.record.insert(db)
            }
        }
    }

    public func updateContact(_ contact: Contact, deleteAddressIds: [String], addresses: [ContactAddress]) throws {
        try db.write { db in
            try ContactRecord
                .filter(ContactRecord.Columns.id == contact.id)
                .updateAll(db, [
                    ContactRecord.Columns.name.set(to: contact.name),
                    ContactRecord.Columns.description.set(to: contact.description),
                    ContactRecord.Columns.updatedAt.set(to: contact.updatedAt),
                ])

            if deleteAddressIds.isNotEmpty {
                try ContactAddressRecord
                    .filter(deleteAddressIds.contains(ContactAddressRecord.Columns.id))
                    .deleteAll(db)
            }

            for address in addresses {
                try address.record.upsert(db)
            }
        }
    }

    public func getAddresses(contactId: String) throws -> [ContactAddress] {
        try db.read { db in
            try ContactAddressRecord
                .filter(ContactAddressRecord.Columns.contactId == contactId)
                .fetchAll(db)
                .map { $0.contactAddress }
        }
    }

    @discardableResult
    public func deleteContact(id: String) throws -> Bool {
        try db.write { db in
            try ContactRecord.deleteOne(db, key: id)
        }
    }
}
