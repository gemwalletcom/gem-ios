// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB
import BigInt

public struct AssetBalanceRecord: Codable, FetchableRecord, PersistableRecord  {
    
    public static let databaseTableName: String = "balances"

    public var assetId: String
    public var walletId: String
    
    public var available: String
    public var availableAmount: Double
    
    public var frozen: String
    public var frozenAmount: Double
    
    public var locked: String
    public var lockedAmount: Double
    
    public var staked: String
    public var stakedAmount: Double
    
    public var pending: String
    public var pendingAmount: Double
    
    public var rewards: String
    public var rewardsAmount: Double
    
    public var reserved: String
    public var reservedAmount: Double
    
    public var totalAmount: Double
    
    public var isEnabled: Bool
    public var isHidden: Bool
    public var isPinned: Bool
    
    public var updatedAt: Date?
}

extension AssetBalanceRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column("assetId", .text)
                .notNull()
                .references(AssetRecord.databaseTableName, onDelete: .cascade)
            $0.column("walletId", .text)
                .notNull()
                .indexed()
                .references(WalletRecord.databaseTableName, onDelete: .cascade)
            
            // balances
            $0.column("available", .text).defaults(to: "0")
            $0.column("availableAmount", .numeric).defaults(to: 0)
            
            $0.column("frozen", .text).defaults(to: "0")
            $0.column("frozenAmount", .double).defaults(to: 0)
            
            $0.column("locked", .text).defaults(to: "0")
            $0.column("lockedAmount", .double).defaults(to: 0)
            
            $0.column("staked", .text).defaults(to: "0")
            $0.column("stakedAmount", .double).defaults(to: 0)
            
            $0.column("pending", .text).defaults(to: "0")
            $0.column("pendingAmount", .double).defaults(to: 0)
            
            $0.column("rewards", .text).defaults(to: "0")
            $0.column("rewardsAmount", .double).defaults(to: 0)
            
            $0.column("reserved", .text).defaults(to: "0")
            $0.column("reservedAmount", .double).defaults(to: 0)
            
            $0.column(sql: totalAmountSQlCreation)
            
            $0.column("isEnabled", .boolean).defaults(to: true).indexed()
            $0.column("isHidden", .boolean).defaults(to: false).indexed()
            $0.column("isPinned", .boolean).defaults(to: false).indexed()
            
            $0.column("updatedAt", .date)
            $0.uniqueKey(["assetId", "walletId"])
        }
    }
    
    static let totalAmountSQlCreation = "totalAmount DOUBLE AS (availableAmount + frozenAmount + lockedAmount + stakedAmount + pendingAmount + rewardsAmount + reservedAmount)"
}

extension AssetBalanceRecord: Identifiable {
    public var id: String { assetId }
}

extension AssetBalanceRecord {
    func mapToBalance() -> Balance {
        return Balance(
            available: BigInt(stringLiteral: available),
            frozen: BigInt(stringLiteral: frozen),
            locked: BigInt(stringLiteral: locked),
            staked: BigInt(stringLiteral: staked),
            pending: BigInt(stringLiteral: pending),
            reserved: BigInt(stringLiteral: reserved)
        )
    }
    
    func mapToAssetBalance() -> AssetBalance {
        return AssetBalance(
            assetId: try! AssetId(id: assetId),
            balance: mapToBalance()
        )
    }
    
    func mapToWalletAssetBalanace() -> WalletAssetBalance {
        return WalletAssetBalance(
            walletId: walletId,
            balance: mapToAssetBalance()
        )
    }
}
