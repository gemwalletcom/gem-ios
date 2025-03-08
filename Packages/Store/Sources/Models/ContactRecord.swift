// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
@preconcurrency import GRDB

public struct ContactRecord: Identifiable, Codable, PersistableRecord, FetchableRecord, TableRecord {
    public static let databaseTableName: String = "contacts"
    
    public var id: String
    public var name: String
    public let description: String?

    static let addresses = hasMany(ContactAddressRecord.self)
}

extension ContactRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column(Columns.Contact.id.name, .text)
                .primaryKey()
                .notNull()
            $0.column(Columns.Contact.name.name, .text)
                .notNull()
                .indexed()
            $0.column(Columns.Contact.description.name, .text)
                .indexed()
        }
    }
}

public extension ContactRecord {
    var contact: Contact {
        Contact(
            id: ContactId(id: id),
            name: name,
            description: description
        )
    }
}

public extension Contact {
    var record: ContactRecord {
        ContactRecord(
            id: id.id,
            name: name,
            description: description
        )
    }
}
