// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct ContactStore: Sendable {

    let db: DatabaseQueue

    public init(db: DB) {
        self.db = db.dbQueue
    }

    public func saveContact(_ contact: Contact, addresses: [ContactAddress]) throws {
        try db.write { db in
            try contact.record.upsert(db)

            try ContactAddressRecord
                .filter(ContactAddressRecord.Columns.contactId == contact.id)
                .filter(!addresses.map { $0.id }.contains(ContactAddressRecord.Columns.id))
                .deleteAll(db)

            for address in addresses {
                try address.record.upsert(db)
            }
        }
    }

    @discardableResult
    public func deleteContact(id: String) throws -> Bool {
        try db.write { db in
            try ContactRecord.deleteOne(db, key: id)
        }
    }
}
