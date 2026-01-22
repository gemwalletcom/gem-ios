// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

struct WalletIdMigration {

    private static let childTables = [
        AccountRecord.databaseTableName,
        BalanceRecord.databaseTableName,
        BannerRecord.databaseTableName,
        NFTAssetAssociationRecord.databaseTableName,
        NotificationRecord.databaseTableName,
        PerpetualPositionRecord.databaseTableName,
        RecentActivityRecord.databaseTableName,
        StakeDelegationRecord.databaseTableName,
        TransactionRecord.databaseTableName,
        WalletConnectionRecord.databaseTableName,
    ]

    private static let currentWalletKey = "currentWallet"

    static func migrate(db: Database) throws {
        // Step 1: Build wallet mappings (oldId -> newId)
        let mappings = try buildWalletMappings(db: db)

        // Step 2: Find and delete duplicates (keep wallet with lowest order)
        let groups = Dictionary(grouping: mappings, by: { $0.newId })
        for (_, wallets) in groups where wallets.count > 1 {
            let sorted = wallets.sorted { $0.order < $1.order }
            let losers = sorted.dropFirst()
            for loser in losers {
                try db.execute(
                    sql: "DELETE FROM \(WalletRecord.databaseTableName) WHERE id = ?",
                    arguments: [loser.oldId]
                )
            }
        }

        // Step 3: Rename remaining wallets to new ID format
        let remainingMappings = try buildWalletMappings(db: db)
        for mapping in remainingMappings where mapping.oldId != mapping.newId {
            // Update child table references FIRST (before wallet ID changes)
            for table in childTables {
                try db.execute(
                    sql: "UPDATE \(table) SET walletId = ? WHERE walletId = ?",
                    arguments: [mapping.newId, mapping.oldId]
                )
            }

            // Update wallet ID
            try db.execute(sql: """
                UPDATE \(WalletRecord.databaseTableName) SET externalId = id, id = ? WHERE id = ?
            """, arguments: [mapping.newId, mapping.oldId])
        }

        // Step 4: Migrate currentWalletId preference
        migrateCurrentWalletPreference(mappings: remainingMappings)
    }

    private static func migrateCurrentWalletPreference(mappings: [WalletMapping]) {
        let firstWallet = mappings.min(by: { $0.order < $1.order })

        guard let currentId = UserDefaults.standard.string(forKey: currentWalletKey) else {
            if let first = firstWallet {
                UserDefaults.standard.set(first.newId, forKey: currentWalletKey)
            }
            return
        }

        if let mapping = mappings.first(where: { $0.oldId == currentId && $0.oldId != $0.newId }) {
            UserDefaults.standard.set(mapping.newId, forKey: currentWalletKey)
        } else if let first = firstWallet {
            UserDefaults.standard.set(first.newId, forKey: currentWalletKey)
        }
    }

    private static func buildWalletMappings(db: Database) throws -> [WalletMapping] {
        try Row.fetchAll(db, sql: """
            SELECT w.id, w.type, w."order",
                   (SELECT a.address FROM \(AccountRecord.databaseTableName) a
                    WHERE a.walletId = w.id AND a.chain = 'ethereum' LIMIT 1) as ethereumAddress,
                   (SELECT a.address FROM \(AccountRecord.databaseTableName) a
                    WHERE a.walletId = w.id LIMIT 1) as address,
                   (SELECT a.chain FROM \(AccountRecord.databaseTableName) a
                    WHERE a.walletId = w.id LIMIT 1) as chain
            FROM \(WalletRecord.databaseTableName) w
        """).compactMap { row -> WalletMapping? in
            guard let oldId: String = row["id"],
                  let typeRaw: String = row["type"],
                  let type = WalletType(rawValue: typeRaw) else { return nil }

            let newId: String
            switch type {
            case .multicoin:
                guard let address: String = row["ethereumAddress"] else { return nil }
                newId = "multicoin_\(address)"
            case .single, .privateKey, .view:
                guard let address: String = row["address"],
                      let chain: String = row["chain"] else { return nil }
                newId = "\(type.rawValue)_\(chain)_\(address)"
            }
            return WalletMapping(oldId: oldId, newId: newId, order: row["order"] ?? 0)
        }
    }

    struct WalletMapping {
        let oldId: String
        let newId: String
        let order: Int
    }
}
