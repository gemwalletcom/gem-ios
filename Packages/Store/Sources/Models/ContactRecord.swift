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
    
    init(id: String?, name: String, description: String?) {
        self.id = id ?? UUID().uuidString
        self.name = name
        self.description = description
    }
}

extension ContactRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column(Columns.Contact.id.name, .text)
                .primaryKey()
                .notNull()
            $0.column(Columns.Contact.name.name, .text)
                .notNull()
            $0.column(Columns.Contact.description.name, .text)
            $0.uniqueKey([Columns.Contact.name.name])
        }
    }
}

public extension ContactRecord {
    func mapToContact() -> Contact {
        Contact(
            id: ContactId(id: id),
            name: name,
            description: description
        )
    }
}

public extension Contact {
    func mapToRecord() -> ContactRecord {
        ContactRecord(
            id: id.id,
            name: name,
            description: description
        )
    }
}
