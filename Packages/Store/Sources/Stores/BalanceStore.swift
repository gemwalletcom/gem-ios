// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct BalanceStore {
    
    let db: DatabaseQueue

    public init(db: DB) {
        self.db = db.dbQueue
    }
    
    public func addBalance(
        _ balances: [AddBalance],
        for walletId: String
    ) throws {
        try db.write { (db: Database) in
            for balance in balances {
                try balance.mapToAssetBalanceRecord(walletId: walletId)
                    .insert(db, onConflict: .ignore)
            }
        }
    }
    
    public func updateBalances(
        _ balances: [UpdateBalance],
        for walletId: String
    ) throws {
        try db.write { (db: Database) in
            for balance in balances {
                try AssetBalanceRecord
                    .filter(Columns.Balance.walletId == walletId)
                    .filter(Columns.Balance.assetId == balance.assetID)
                    .updateAll(db,[
                        Columns.Balance.available.set(to: balance.available),
                        Columns.Balance.frozen.set(to: balance.frozen),
                        Columns.Balance.locked.set(to: balance.locked),
                        Columns.Balance.staked.set(to: balance.staked),
                        Columns.Balance.pending.set(to: balance.pending),
                        Columns.Balance.reserved.set(to: balance.reserved),
                        Columns.Balance.total.set(to: balance.total),
                        Columns.Balance.fiatValue.set(to: balance.fiatValue),
                        Columns.Balance.updatedAt.set(to: balance.updatedAt),
                    ])
            }
        }
    }
    
    @discardableResult
    public func getBalance(walletId: String, assetId: String) throws -> Balance? {
        try db.read { db in
            return try AssetBalanceRecord
                .filter(Columns.Balance.walletId == walletId)
                .filter(Columns.Balance.assetId == assetId)
                .fetchOne(db)?.mapToBalance()
        }
    }

    @discardableResult
    public func getBalances(assetIds: [String]) throws -> [WalletAssetBalance] {
        try db.read { db in
            return try AssetBalanceRecord
                .filter(assetIds.contains(Columns.Balance.assetId))
                .fetchAll(db)
                .map { $0.mapToWalletAssetBalanace() }
        }
    }
    
    @discardableResult
    public func getEnabledAssetIds() throws -> [AssetId] {
        try db.read { db in
            return try AssetBalanceRecord
                .filter(Columns.Balance.isEnabled == true)
                .fetchAll(db)
                .compactMap { AssetId(id: $0.assetId) }
        }
    }
    
    @discardableResult
    public func getBalances(walletId: String, assetIds: [String]) throws -> [AssetBalance] {
        try db.read { db in
            return try AssetBalanceRecord
                .filter(Columns.Balance.walletId == walletId)
                .filter(assetIds.contains(Columns.Balance.assetId))
                .distinct()
                .fetchAll(db)
                .map { $0.mapToAssetBalance() }
        }
    }
    
    @discardableResult
    public func isBalanceExist(walletId: String, assetId: String) throws -> Bool {
        try db.read { db in
            return try AssetBalanceRecord
                .filter(Columns.Balance.walletId == walletId)
                .filter(Columns.Balance.assetId == assetId)
                .fetchCount(db) > 0
        }
    }
    
    @discardableResult
    public func setIsEnabled(walletId: String, assetIds: [String], value: Bool) throws -> Int {
        try db.write { db in
            return try AssetBalanceRecord
                .filter(Columns.Balance.walletId == walletId)
                .filter(assetIds.contains(Columns.Balance.assetId))
                .updateAll(db, 
                    Columns.Balance.isEnabled.set(to: value),
                    Columns.Balance.isHidden.set(to: !value),
                    Columns.Balance.isPinned.set(to: false)
                )
        }
    }

    @discardableResult
    public func pinAsset(walletId: String, assetId: String, value: Bool) throws -> Int {
        try db.write { db in
            return try AssetBalanceRecord
                .filter(Columns.Balance.walletId == walletId)
                .filter(Columns.Balance.assetId == assetId)
                .updateAll(db, Columns.Balance.isPinned.set(to: value))
        }
    }
}
