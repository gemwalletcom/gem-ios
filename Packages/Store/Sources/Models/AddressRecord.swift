// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct AddressRecord: Codable, FetchableRecord, PersistableRecord, Sendable {
    public static let databaseTableName = "addresses"
    
    public enum Columns {
        static let chain = Column("chain")
        static let address = Column("address")
        static let name = Column("name")
    }
    
    public let chain: Chain
    public let address: String
    public let name: String
    
    public init(
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
