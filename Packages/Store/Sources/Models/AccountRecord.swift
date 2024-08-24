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
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column("walletId", .text)
                .notNull()
                .indexed()
                .references(WalletRecord.databaseTableName, onDelete: .cascade)
            $0.column("chain", .text)
                .notNull()
            $0.column("address", .text)
                .notNull()
            $0.column("extendedPublicKey", .text)
                .notNull()
            $0.column("index", .numeric)
                .defaults(to: 0)
                .notNull()
            $0.column("derivationPath", .text)
                .notNull()
            $0.uniqueKey(["walletId", "chain", "derivationPath", "address"])
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
