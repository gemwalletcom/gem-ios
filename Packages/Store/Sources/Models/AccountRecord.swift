// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB

public struct AccountRecord: Codable, FetchableRecord, PersistableRecord  {
    
    public static var databaseTableName: String = "wallets_accounts"

    public var walletId: String
    public var chain: Chain
    public var address: String
    public var extendedPublicKey: String
    public var index: Int
    public var derivationPath: String
}

extension AccountRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName) { t in
            t.column("walletId", .text)
                .notNull()
                .indexed()
                .references(WalletRecord.databaseTableName, onDelete: .cascade)
            t.column("chain", .text)
                .notNull()
            t.column("address", .text)
                .notNull()
            t.column("extendedPublicKey", .text)
                .notNull()
            t.column("index", .numeric)
                .defaults(to: 0)
                .notNull()
            t.column("derivationPath", .text)
                .notNull()
            t.uniqueKey(["walletId", "chain", "derivationPath", "address"])
        }
    }
}

extension AccountRecord {
    func mapToAccount() -> Account {
        return Account(
            chain: chain,
            address: address,
            derivationPath: derivationPath,
            extendedPublicKey: extendedPublicKey
        )
    }
}
