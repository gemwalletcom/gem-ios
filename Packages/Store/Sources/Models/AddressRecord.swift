// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

struct AddressRecord: Codable, FetchableRecord, PersistableRecord, Sendable {
    static let databaseTableName = "addresses"
    
    enum Columns {
        static let chain = Column("chain")
        static let address = Column("address")
        static let name = Column("name")
    }
    
    let chain: Chain
    let address: String
    let name: String
    
    init(
        chain: Chain,
        address: String,
        name: String
    ) {
        self.chain = chain
        self.address = address
        self.name = name
    }
}

extension AddressRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName) {
            $0.column(Columns.chain.name, .text)
                .notNull()
                .references(AssetRecord.databaseTableName, onDelete: .cascade, onUpdate: .cascade)
            $0.column(Columns.address.name, .text)
                .notNull()
            $0.column(Columns.name.name, .text)
                .notNull()
            $0.primaryKey([Columns.chain.name, Columns.address.name])
        }
    }
}

extension AddressRecord {
    func asPrimitive() -> AddressName {
        AddressName(
            chain: chain,
            address: address,
            name: name
        )
    }
}
