// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
@preconcurrency import GRDB

public struct ContactAddressRecord: Codable, PersistableRecord, FetchableRecord {
    
    public static let databaseTableName: String = "contact_addresses"
    
    public let id: String
    public let contactId: String?
    public let address: String
    public let chain: Chain
    public let memo: String?
    
    static let contact = belongsTo(ContactRecord.self).forKey("contact")
    
    public init(
        id: String?,
        contactId: String?,
        address: String,
        chain: Chain,
        memo: String?
    ) {
        self.id = id ?? UUID().uuidString
        self.contactId = contactId
        self.address = address
        self.chain = chain
        self.memo = memo
    }
}

extension ContactAddressRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.primaryKey(Columns.ContactAddress.id.name, .text)
                .notNull()
                .indexed()
            $0.column(Columns.ContactAddress.contactId.name, .text)
                .notNull()
                .indexed()
                .references(ContactRecord.databaseTableName, onDelete: .cascade)
            $0.column(Columns.ContactAddress.address.name, .text)
                .notNull()
            $0.column(Columns.ContactAddress.memo.name, .text)
                .notNull()
            $0.column(Columns.ContactAddress.chain.name, .text)
                .notNull()
            $0.uniqueKey([
                Columns.ContactAddress.contactId.name,
                Columns.ContactAddress.chain.name,
                Columns.ContactAddress.address.name,
                Columns.ContactAddress.memo.name
            ])
        }
    }
}

public extension ContactAddressRecord {
    func mapToAddress(with contact: Contact) -> ContactAddress {
        ContactAddress(
            id: id,
            contact: contact,
            address: address,
            chain: chain,
            memo: memo
        )
    }
}

public extension ContactAddress {
    func mapToRecord() -> ContactAddressRecord {
        ContactAddressRecord(
            id: id,
            contactId: contact.id.id,
            address: address,
            chain: chain,
            memo: memo
        )
    }
}
