// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct ContactRecord: Codable, FetchableRecord, PersistableRecord {

    public static let databaseTableName: String = "contacts"

    public enum Columns {
        static let id = Column("id")
        static let name = Column("name")
        static let address = Column("address")
        static let chain = Column("chain")
        static let memo = Column("memo")
        static let description = Column("description")
    }

    public var id: String
    public var name: String
    public var address: String
    public var chain: Chain
    public var memo: String?
    public var description: String?
}

extension ContactRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.primaryKey(Columns.id.name, .text)
                .notNull()
            $0.column(Columns.name.name, .text)
                .notNull()
            $0.column(Columns.address.name, .text)
                .notNull()
            $0.column(Columns.chain.name, .text)
                .notNull()
            $0.column(Columns.memo.name, .text)
            $0.column(Columns.description.name, .text)
        }
    }
}

extension ContactRecord {
    func mapToContact() -> Contact {
        Contact(
            name: name,
            address: address,
            chain: chain,
            memo: memo,
            description: description
        )
    }
}

extension Contact {
    var record: ContactRecord {
        ContactRecord(
            id: id,
            name: name,
            address: address,
            chain: chain,
            memo: memo,
            description: description
        )
    }
}
