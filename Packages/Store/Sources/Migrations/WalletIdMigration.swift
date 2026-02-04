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
        StakePositionRecord.databaseTableName,
        TransactionRecord.databaseTableName,
        WalletConnectionRecord.databaseTableName,
    ]

    private static let currentWalletKey = "currentWallet"

    static func migrate(db: Database, userDefaults: UserDefaults = .standard) throws {
        let mappings = try buildWalletMappings(db: db)
        if mappings.isEmpty {
            return
        }
        
        try db.execute(sql: "PRAGMA foreign_keys = OFF")

        let groups = Dictionary(grouping: mappings, by: { $0.newId })
        for (_, wallets) in groups where wallets.count > 1 {
            let sorted = wallets.sorted { $0.order < $1.order }
            let losers = sorted.dropFirst()
            for loser in losers {
                for table in childTables {
                    try? db.execute(sql: "DELETE FROM \(table) WHERE walletId = ?", arguments: [loser.oldId])
                }
                try db.execute(sql: "DELETE FROM \(WalletRecord.databaseTableName) WHERE id = ?", arguments: [loser.oldId])
            }
        }

        let remainingMappings = try buildWalletMappings(db: db)
        for mapping in remainingMappings where mapping.oldId != mapping.newId {
            try db.execute(sql: "UPDATE \(WalletRecord.databaseTableName) SET externalId = id, id = ? WHERE id = ?", arguments: [mapping.newId, mapping.oldId])

            for table in childTables {
                try? db.execute(sql: "UPDATE \(table) SET walletId = ? WHERE walletId = ?", arguments: [mapping.newId, mapping.oldId])
            }

            // Delete banners with old wallet IDs (their computed id won't match the stored id)
            try? db.execute(sql: "DELETE FROM \(BannerRecord.databaseTableName) WHERE walletId = ?", arguments: [mapping.newId])

            migrateWalletPreferences(oldId: mapping.oldId, newId: mapping.newId)
        }

        cleanupOrphanedRecords(db: db)

        try db.execute(sql: "PRAGMA foreign_keys = ON")

        migrateCurrentWalletPreference(mappings: remainingMappings, userDefaults: userDefaults)
    }

    private static func cleanupOrphanedRecords(db: Database) {
        do {
            let violations = try Row.fetchAll(db, sql: "PRAGMA foreign_key_check")
            for violation in violations {
                if let table = violation["table"] as? String,
                   let rowid = violation["rowid"] as? Int64 {
                    try? db.execute(sql: "DELETE FROM \(table) WHERE rowid = ?", arguments: [rowid])
                }
            }
        } catch {
            // Silently continue if check fails
        }
    }

    private static func migrateWalletPreferences(oldId: String, newId: String) {
        let oldSuiteName = "wallet_preferences_\(oldId)_v2"
        let newSuiteName = "wallet_preferences_\(newId)_v2"

        guard let oldDefaults = UserDefaults(suiteName: oldSuiteName),
              let newDefaults = UserDefaults(suiteName: newSuiteName) else { return }

        for (key, value) in oldDefaults.dictionaryRepresentation() {
            newDefaults.set(value, forKey: key)
        }

        oldDefaults.removePersistentDomain(forName: oldSuiteName)
    }

    private static func migrateCurrentWalletPreference(mappings: [WalletMapping], userDefaults: UserDefaults) {
        let firstWallet = mappings.min(by: { $0.order < $1.order })

        guard let currentId = userDefaults.string(forKey: currentWalletKey) else {
            if let first = firstWallet {
                userDefaults.set(first.newId, forKey: currentWalletKey)
            }
            return
        }

        if let mapping = mappings.first(where: { $0.oldId == currentId }) {
            userDefaults.set(mapping.newId, forKey: currentWalletKey)
        } else if let first = firstWallet {
            userDefaults.set(first.newId, forKey: currentWalletKey)
        }
    }

    private static func buildWalletMappings(db: Database) throws -> [WalletMapping] {
        try Row.fetchAll(db, sql: """
            SELECT w.id, w.type, w."order",
                   (SELECT a.address FROM \(AccountRecord.databaseTableName) a
                    WHERE a.walletId = w.id AND a.chain = 'ethereum'
                    ORDER BY a.address LIMIT 1) as ethereumAddress,
                   (SELECT a.address FROM \(AccountRecord.databaseTableName) a
                    WHERE a.walletId = w.id
                    ORDER BY a.address LIMIT 1) as address,
                   (SELECT a.chain FROM \(AccountRecord.databaseTableName) a
                    WHERE a.walletId = w.id
                    ORDER BY a.address LIMIT 1) as chain
            FROM \(WalletRecord.databaseTableName) w
        """).compactMap { row -> WalletMapping? in
            guard let oldId: String = row["id"],
                  let typeRaw: String = row["type"],
                  let type = WalletType(rawValue: typeRaw) else { return nil }

            let newId: String
            switch type {
            case .multicoin:
                guard let address: String = row["ethereumAddress"] else {
                    return nil
                }
                newId = "multicoin_\(address)"
            case .single, .privateKey, .view:
                guard let address: String = row["address"],
                      let chain: String = row["chain"] else {
                    return nil
                }
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
