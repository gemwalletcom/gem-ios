// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB

public struct AccountRecord: Codable, FetchableRecord, PersistableRecord  {
    
    public static let databaseTableName: String = "wallets_accounts"

    public var walletId: String
    public var chain: Chain
    public var address: String
    public var publicKey: String?
    public var extendedPublicKey: String?
    public var index: Int
    public var derivationPath: String
}

extension AccountRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column(Columns.Account.walletId.name, .text)
                .notNull()
                .indexed()
                .references(WalletRecord.databaseTableName, onDelete: .cascade)
            $0.column(Columns.Account.chain.name, .text)
                .notNull()
            $0.column(Columns.Account.address.name, .text)
                .notNull()
            $0.column(Columns.Account.publicKey.name, .text)
            $0.column(Columns.Account.extendedPublicKey.name, .text)
            $0.column(Columns.Account.index.name, .numeric)
                .defaults(to: 0)
                .notNull()
            $0.column(Columns.Account.derivationPath.name, .text)
                .notNull()
            $0.uniqueKey([
                Columns.Account.walletId.name,
                Columns.Account.chain.name,
                Columns.Account.derivationPath.name,
                Columns.Account.address.name
            ])
        }
    }
}

extension AccountRecord {
    func mapToAccount() -> Account {
        return Account(
            chain: chain,
            address: address,
            derivationPath: derivationPath,
            publicKey: publicKey,
            extendedPublicKey: extendedPublicKey
        )
    }
}
