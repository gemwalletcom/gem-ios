// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Primitives
import SwiftUICore

public struct ContactStore: Sendable {
    let db: DatabaseQueue
    
    public init(db: DB) {
        self.db = db.dbQueue
    }
    
    public func addContact(record: ContactRecord) throws {
        try db.write { db in
            try record.insert(db, onConflict: .replace)
        }
    }
    
    public func addAddress(record: ContactAddressRecord) throws {
        try db.write { db in
            try record.insert(db, onConflict: .replace)
        }
    }
    
    public func editContact(record: ContactRecord) throws {
        try db.write { db in
            try record.update(db)
        }
    }
    
    public func editAddress(record: ContactAddressRecord) throws {
        try db.write { db in
            try record.update(db)
        }
    }
    
    public func deleteContact(record: ContactRecord) throws -> Bool {
        try db.write { db in
            try record.delete(db)
        }
    }
    
    public func deleteAddress(record: ContactAddressRecord) throws -> Bool {
        try db.write { db in
            try record.delete(db)
        }
    }
}
