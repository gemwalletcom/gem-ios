// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct ContactRecord: Codable, FetchableRecord, PersistableRecord, Sendable, Equatable {

    public static let databaseTableName: String = "contacts"

    public enum Columns {
        static let id = Column("id")
        static let name = Column("name")
        static let description = Column("description")
        static let createdAt = Column("createdAt")
        static let updatedAt = Column("updatedAt")
    }

    public var id: String
    public var name: String
    public var description: String?
    public var createdAt: Date
    public var updatedAt: Date

    static let addresses = hasMany(ContactAddressRecord.self).forKey("addresses")
}

extension ContactRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.primaryKey(Columns.id.name, .text)
                .notNull()
            $0.column(Columns.name.name, .text)
                .notNull()
            $0.column(Columns.description.name, .text)
            $0.column(Columns.createdAt.name, .date)
                .notNull()
            $0.column(Columns.updatedAt.name, .date)
                .notNull()
        }
    }
}

extension ContactRecord {
    var contact: Contact {
        Contact(
            id: id,
            name: name,
            description: description,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

extension Contact {
    var record: ContactRecord {
        ContactRecord(
            id: id,
            name: name,
            description: description,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
