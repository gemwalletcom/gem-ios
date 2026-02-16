// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct ContactStore: Sendable {

    let db: DatabaseQueue

    public init(db: DB) {
        self.db = db.dbQueue
    }

    public func addContact(_ contact: Contact) throws {
        try db.write { db in
            try contact.record.insert(db)
        }
    }

    public func updateContact(_ contact: Contact) throws {
        try db.write { db in
            try contact.record.update(db)
        }
    }

    @discardableResult
    public func deleteContact(id: String) throws -> Bool {
        try db.write { db in
            try ContactRecord.deleteOne(db, key: id)
        }
    }
}
