// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB

public struct WalletRecord: Codable, TableRecord, FetchableRecord, PersistableRecord  {
    public static let databaseTableName: String = "wallets"
    
    public struct Columns {
        static let id = Column("id")
        static let name = Column("name")
        static let index = Column("index")
        static let type = Column("type")
        static let order = Column("order")
        static let isPinned = Column("isPinned")
        static let imageUrl = Column("imageUrl")
        static let updatedAt = Column("updatedAt")
        static let isCreated = Column("isCreated")
    }

    public var id: String
    public var name: String
    public var type: String
    public var index: Int
    public var order: Int
    public var isPinned: Bool
    public var imageUrl: String?
    public var updatedAt: Date?
    public var isCreated: Bool

    static let accounts = hasMany(AccountRecord.self).forKey("accounts")
    static let connection = hasOne(WalletConnectionRecord.self).forKey("connection")
}

extension WalletRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName) {
            $0.column(Columns.id.name, .text)
                .primaryKey()
                .notNull()
            $0.column(Columns.name.name, .text)
                .notNull()
            $0.column(Columns.type.name, .text)
                .notNull()
            $0.column(Columns.index.name, .numeric)
                .notNull()
                .defaults(to: 0)
            $0.column(Columns.order.name, .numeric)
                .notNull()
                .defaults(to: 0)
            $0.column(Columns.isPinned.name, .boolean)
                .defaults(to: false)
            $0.column(Columns.imageUrl.name, .text)
            $0.column(Columns.updatedAt.name, .date)
            $0.column(Columns.isCreated.name, .boolean)
                .defaults(to: false)
        }
    }
}
