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
                        Columns.Balance.available.set(to: balance.available.value),
                        Columns.Balance.availableAmount.set(to: balance.available.amount),
                        Columns.Balance.reserved.set(to: balance.reserved.value),
                        Columns.Balance.reservedAmount.set(to: balance.reserved.amount)
                    ]
                case .token(let balance):
                    [
                        Columns.Balance.available.set(to: balance.available.value),
                        Columns.Balance.availableAmount.set(to: balance.available.amount),
                    ]
                case .stake(let balance):
                    [
                        Columns.Balance.staked.set(to: balance.staked.value),
                        Columns.Balance.stakedAmount.set(to: balance.staked.amount),
                        Columns.Balance.frozen.set(to: balance.frozen.value),
                        Columns.Balance.frozenAmount.set(to: balance.frozen.amount),
                        Columns.Balance.locked.set(to: balance.locked.value),
                        Columns.Balance.lockedAmount.set(to: balance.locked.amount),
                        Columns.Balance.pending.set(to: balance.pending.value),
                        Columns.Balance.pendingAmount.set(to: balance.pending.amount),
                        Columns.Balance.rewards.set(to: balance.rewards.value),
                        Columns.Balance.rewardsAmount.set(to: balance.rewards.amount),
                    ]
                }
                
                let defaultFields: [ColumnAssignment] = [
                    Columns.Balance.updatedAt.set(to: balance.updatedAt),
                    Columns.Balance.isActive.set(to: balance.isActive),
                ]
                let assignments = balanceFields + defaultFields
                
                try BalanceRecord
                    .filter(Columns.Balance.walletId == walletId)
                    .filter(Columns.Balance.assetId == balance.assetID)
                    .updateAll(db, assignments)
            }
        }
    }
    
    @discardableResult
    public func getBalance(walletId: String, assetId: String) throws -> Balance? {
        try db.read { db in
            return try BalanceRecord
                .filter(Columns.Balance.walletId == walletId)
                .filter(Columns.Balance.assetId == assetId)
                .fetchOne(db)?.mapToBalance()
        }
    }

    @discardableResult
    public func getBalances(assetIds: [String]) throws -> [WalletAssetBalance] {
        try db.read { db in
            return try BalanceRecord
                .filter(assetIds.contains(Columns.Balance.assetId))
                .fetchAll(db)
                .map { $0.mapToWalletAssetBalanace() }
        }
    }
    
    @discardableResult
    public func getEnabledAssetIds() throws -> [AssetId] {
        try db.read { db in
            return try BalanceRecord
                .filter(Columns.Balance.isEnabled == true)
                .fetchAll(db)
                .compactMap { try? AssetId(id: $0.assetId) }
        }
    }
    
    @discardableResult
    public func getBalances(walletId: String, assetIds: [String]) throws -> [AssetBalance] {
        try db.read { db in
            return try BalanceRecord
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
            return try BalanceRecord
                .filter(Columns.Balance.walletId == walletId)
                .filter(Columns.Balance.assetId == assetId)
                .fetchCount(db) > 0
        }
    }
    
    @discardableResult
    public func setIsEnabled(walletId: String, assetIds: [String], value: Bool) throws -> Int {
        try db.write { db in
            let assigments = switch value {
            case true: [
                Columns.Balance.isEnabled.set(to: true),
                Columns.Balance.isHidden.set(to: false),
            ]
            case false: [
                Columns.Balance.isEnabled.set(to: false),
                Columns.Balance.isHidden.set(to: true),
                Columns.Balance.isPinned.set(to: false)
            ]}
            
            return try BalanceRecord
                .filter(Columns.Balance.walletId == walletId)
                .filter(assetIds.contains(Columns.Balance.assetId))
                .updateAll(db, assigments)
        }
    }

    @discardableResult
    public func pinAsset(walletId: String, assetId: String, value: Bool) throws -> Int {
        try db.write { db in
            return try BalanceRecord
                .filter(Columns.Balance.walletId == walletId)
                .filter(Columns.Balance.assetId == assetId)
                .updateAll(db, Columns.Balance.isPinned.set(to: value))
        }
    }
}
