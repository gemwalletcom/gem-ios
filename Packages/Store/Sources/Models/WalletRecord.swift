// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
@preconcurrency import GRDB

public struct WalletRecord: Codable, TableRecord, FetchableRecord, PersistableRecord  {
    
    public static let databaseTableName: String = "wallets"

    public var id: String
    public var name: String
    public var type: String
    public var index: Int
    public var order: Int
    public var isPinned: Bool

    static let accounts = hasMany(AccountRecord.self).forKey("accounts")
    static let connection = hasOne(WalletConnectionRecord.self).forKey("connection")
}

extension WalletRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName) {
            $0.column(Columns.Wallet.id.name, .text)
                .primaryKey()
                .notNull()
            $0.column(Columns.Wallet.name.name, .text)
                .notNull()
            $0.column(Columns.Wallet.type.name, .text)
                .notNull()
            $0.column(Columns.Wallet.index.name, .numeric)
                .notNull()
                .defaults(to: 0)
            $0.column(Columns.Wallet.order.name, .numeric)
                .notNull()
                .defaults(to: 0)
            $0.column(Columns.Wallet.isPinned.name, .boolean)
                .defaults(to: false)
        }
    }
}
