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
    
    public func addContact(_ contact: Contact) throws -> ContactId {
        try db.write { db in
            let record = contact.mapToRecord()
            try record.insert(db, onConflict: .abort)
            return ContactId(id: record.id)
        }
    }
    
    public func addAddress(_ address: ContactAddress) throws {
        try db.write { db in
            try address.mapToRecord().insert(db, onConflict: .abort)
        }
    }
    
    public func editContact(_ contact: Contact) throws {
        try db.write { db in
            try contact.mapToRecord().update(db)
        }
    }
    
    public func editAddress(_ address: ContactAddress) throws {
        try db.write { db in
            try address.mapToRecord().update(db)
        }
    }
    
    public func deleteContact(_ contact: Contact) throws -> Bool {
        try db.write { db in
            try contact.mapToRecord().delete(db)
        }
    }
    
    public func deleteAddress(_ address: ContactAddress) throws -> Bool {
        try db.write { db in
            try address.mapToRecord().delete(db)
        }
    }
}
