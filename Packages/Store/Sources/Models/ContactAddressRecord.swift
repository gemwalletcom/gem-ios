// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
@preconcurrency import GRDB

public struct ContactAddressRecord: Identifiable, Codable, PersistableRecord, FetchableRecord, TableRecord {
    
    public static let databaseTableName: String = "contact_addresses"
    
    public var id: String
    public let contactId: String
    public let value: String
    public let chain: Chain
    public let memo: String?
    
    static let contact = belongsTo(ContactRecord.self).forKey("contact")
    
    public init(
        id: String,
        contactId: String,
        value: String,
        chain: Chain,
        memo: String?
    ) {
        self.id = id
        self.contactId = contactId
        self.value = value
        self.chain = chain
        self.memo = memo
    }
}

extension ContactAddressRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column(Columns.ContactAddress.id.name, .text)
                .primaryKey()
                .notNull()
            $0.column(Columns.ContactAddress.contactId.name, .text)
                .notNull()
                .indexed()
                .references(ContactRecord.databaseTableName, onDelete: .cascade)
            $0.column(Columns.ContactAddress.value.name, .text)
                .notNull()
                .indexed()
            $0.column(Columns.ContactAddress.memo.name, .text)
                .indexed()
            $0.column(Columns.ContactAddress.chain.name, .text)
                .notNull()
                .indexed()
        }
    }
}

public extension ContactAddressRecord {
    var address: ContactAddress {
        ContactAddress(
            id: ContactAddressId(id: id),
            contactId: ContactId(id: contactId),
            value: value,
            chain: chain,
            memo: memo
        )
    }
}

public extension ContactAddress {
    var record: ContactAddressRecord {
        ContactAddressRecord(
            id: id.id,
            contactId: contactId.id,
            value: value,
            chain: chain,
            memo: memo
        )
    }
}
