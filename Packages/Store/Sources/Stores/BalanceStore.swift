// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct BalanceStore: Sendable {
    
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
                let balanceFields: [ColumnAssignment] = switch balance.type {
                case .coin(let balance):
                    [
                        BalanceRecord.Columns.available.set(to: balance.available.value),
                        BalanceRecord.Columns.availableAmount.set(to: balance.available.amount),
                        BalanceRecord.Columns.reserved.set(to: balance.reserved.value),
                        BalanceRecord.Columns.reservedAmount.set(to: balance.reserved.amount)
                    ]
                case .token(let balance):
                    [
                        BalanceRecord.Columns.available.set(to: balance.available.value),
                        BalanceRecord.Columns.availableAmount.set(to: balance.available.amount),
                    ]
                case .stake(let balance):
                    [
                        BalanceRecord.Columns.staked.set(to: balance.staked.value),
                        BalanceRecord.Columns.stakedAmount.set(to: balance.staked.amount),
                        BalanceRecord.Columns.frozen.set(to: balance.frozen.value),
                        BalanceRecord.Columns.frozenAmount.set(to: balance.frozen.amount),
                        BalanceRecord.Columns.locked.set(to: balance.locked.value),
                        BalanceRecord.Columns.lockedAmount.set(to: balance.locked.amount),
                        BalanceRecord.Columns.pending.set(to: balance.pending.value),
                        BalanceRecord.Columns.pendingAmount.set(to: balance.pending.amount),
                        BalanceRecord.Columns.rewards.set(to: balance.rewards.value),
                        BalanceRecord.Columns.rewardsAmount.set(to: balance.rewards.amount),
                    ]
                }
                
                let defaultFields: [ColumnAssignment] = [
                    BalanceRecord.Columns.updatedAt.set(to: balance.updatedAt),
                    BalanceRecord.Columns.isActive.set(to: balance.isActive),
                ]
                let assignments = balanceFields + defaultFields
                
                try BalanceRecord
                    .filter(BalanceRecord.Columns.walletId == walletId)
                    .filter(BalanceRecord.Columns.assetId == balance.assetID)
                    .updateAll(db, assignments)
            }
        }
    }
    
    @discardableResult
    public func getBalance(walletId: String, assetId: String) throws -> Balance? {
        try db.read { db in
            return try BalanceRecord
                .filter(BalanceRecord.Columns.walletId == walletId)
                .filter(BalanceRecord.Columns.assetId == assetId)
                .fetchOne(db)?.mapToBalance()
        }
    }

    @discardableResult
    public func getBalances(assetIds: [String]) throws -> [WalletAssetBalance] {
        try db.read { db in
            return try BalanceRecord
                .filter(assetIds.contains(BalanceRecord.Columns.assetId))
                .fetchAll(db)
                .map { $0.mapToWalletAssetBalanace() }
        }
    }
    
    @discardableResult
    public func getEnabledAssetIds() throws -> [AssetId] {
        try db.read { db in
            return try BalanceRecord
                .filter(BalanceRecord.Columns.isEnabled == true)
                .fetchAll(db)
                .compactMap { $0.assetId }
        }
    }
    
    @discardableResult
    public func getBalances(walletId: String, assetIds: [String]) throws -> [AssetBalance] {
        try db.read { db in
            return try BalanceRecord
                .filter(BalanceRecord.Columns.walletId == walletId)
                .filter(assetIds.contains(BalanceRecord.Columns.assetId))
                .distinct()
                .fetchAll(db)
                .map { $0.mapToAssetBalance() }
        }
    }
    
    @discardableResult
    public func isBalanceExist(walletId: String, assetId: String) throws -> Bool {
        try db.read { db in
            return try BalanceRecord
                .filter(BalanceRecord.Columns.walletId == walletId)
                .filter(BalanceRecord.Columns.assetId == assetId)
                .fetchCount(db) > 0
        }
    }
    
    @discardableResult
    public func setIsEnabled(walletId: String, assetIds: [String], value: Bool) throws -> Int {
        try db.write { db in
            let assigments = switch value {
            case true: [
                BalanceRecord.Columns.isEnabled.set(to: true),
                BalanceRecord.Columns.isHidden.set(to: false),
            ]
            case false: [
                BalanceRecord.Columns.isEnabled.set(to: false),
                BalanceRecord.Columns.isHidden.set(to: true),
                BalanceRecord.Columns.isPinned.set(to: false)
            ]}
            
            return try BalanceRecord
                .filter(BalanceRecord.Columns.walletId == walletId)
                .filter(assetIds.contains(BalanceRecord.Columns.assetId))
                .updateAll(db, assigments)
        }
    }

    @discardableResult
    public func pinAsset(walletId: String, assetId: String, value: Bool) throws -> Int {
        try db.write { db in
            return try BalanceRecord
                .filter(BalanceRecord.Columns.walletId == walletId)
                .filter(BalanceRecord.Columns.assetId == assetId)
                .updateAll(db, BalanceRecord.Columns.isPinned.set(to: value))
        }
    }
}
