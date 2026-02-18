// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct ContactAddressRecord: Codable, FetchableRecord, PersistableRecord, Sendable, Equatable {

    public static let databaseTableName: String = "contact_addresses"

    public enum Columns {
        static let id = Column("id")
        static let contactId = Column("contactId")
        static let address = Column("address")
        static let chain = Column("chain")
        static let memo = Column("memo")
        static let description = Column("description")
    }

    public var id: String
    public var contactId: String
    public var address: String
    public var chain: Chain
    public var memo: String?
    public var description: String?

    static let contact = belongsTo(ContactRecord.self).forKey("contact")
}

extension ContactAddressRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.primaryKey(Columns.id.name, .text)
                .notNull()
            $0.column(Columns.contactId.name, .text)
                .notNull()
                .indexed()
                .references(ContactRecord.databaseTableName, onDelete: .cascade)
            $0.column(Columns.address.name, .text)
                .notNull()
            $0.column(Columns.chain.name, .text)
                .notNull()
            $0.column(Columns.memo.name, .text)
            $0.column(Columns.description.name, .text)
        }
    }
}

extension ContactAddressRecord {
    var contactAddress: ContactAddress {
        ContactAddress(
            id: id,
            contactId: contactId,
            address: address,
            chain: chain,
            memo: memo,
            description: description
        )
    }
}

extension ContactAddress {
    var record: ContactAddressRecord {
        ContactAddressRecord(
            id: id,
            contactId: contactId,
            address: address,
            chain: chain,
            memo: memo,
            description: description
        )
    }
}
