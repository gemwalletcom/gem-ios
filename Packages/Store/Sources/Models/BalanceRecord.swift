// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB
import BigInt

public struct BalanceRecord: Codable, FetchableRecord, PersistableRecord  {
    
    public static let databaseTableName: String = "balances"
    
    public enum Columns {
        static let assetId = Column("assetId")
        static let walletId = Column("walletId")
        static let isEnabled = Column("isEnabled")
        static let isPinned = Column("isPinned")
        static let isActive = Column("isActive")
        static let available = Column("available")
        static let availableAmount = Column("availableAmount")
        static let frozen = Column("frozen")
        static let frozenAmount = Column("frozenAmount")
        static let locked = Column("locked")
        static let lockedAmount = Column("lockedAmount")
        static let staked = Column("staked")
        static let stakedAmount = Column("stakedAmount")
        static let pending = Column("pending")
        static let pendingAmount = Column("pendingAmount")
        static let pendingUnconfirmed = Column("pendingUnconfirmed")
        static let pendingUnconfirmedAmount = Column("pendingUnconfirmedAmount")
        static let rewards = Column("rewards")
        static let rewardsAmount = Column("rewardsAmount")
        static let reserved = Column("reserved")
        static let reservedAmount = Column("reservedAmount")
        static let withdrawable = Column("withdrawable")
        static let withdrawableAmount = Column("withdrawableAmount")
        static let yield = Column("yield")
        static let yieldAmount = Column("yieldAmount")
        static let totalAmount = Column("totalAmount")
        static let metadata = Column("metadata")
        static let lastUsedAt = Column("lastUsedAt")
        static let updatedAt = Column("updatedAt")
    }

    public var assetId: AssetId
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

    public var pendingUnconfirmed: String
    public var pendingUnconfirmedAmount: Double

    public var rewards: String
    public var rewardsAmount: Double
    
    public var reserved: String
    public var reservedAmount: Double
    
    public var withdrawable: String
    public var withdrawableAmount: Double

    public var yield: String
    public var yieldAmount: Double

    public var totalAmount: Double
    
    public var isEnabled: Bool
    public var isPinned: Bool
    public var isActive: Bool
    
    public var metadata: BalanceMetadata?

    public var lastUsedAt: Date?
    public var updatedAt: Date?
}

extension BalanceRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column(Columns.assetId.name, .text)
                .notNull()
                .references(AssetRecord.databaseTableName, onDelete: .cascade, onUpdate: .cascade)
            $0.column(Columns.walletId.name, .text)
                .notNull()
                .indexed()
                .references(WalletRecord.databaseTableName, onDelete: .cascade, onUpdate: .cascade)
            
            // balances
            $0.column(Columns.available.name, .text).defaults(to: "0")
            $0.column(Columns.availableAmount.name, .numeric).defaults(to: 0)
            
            $0.column(Columns.frozen.name, .text).defaults(to: "0")
            $0.column(Columns.frozenAmount.name, .double).defaults(to: 0)
            
            $0.column(Columns.locked.name, .text).defaults(to: "0")
            $0.column(Columns.lockedAmount.name, .double).defaults(to: 0)
            
            $0.column(Columns.staked.name, .text).defaults(to: "0")
            $0.column(Columns.stakedAmount.name, .double).defaults(to: 0)
            
            $0.column(Columns.pending.name, .text).defaults(to: "0")
            $0.column(Columns.pendingAmount.name, .double).defaults(to: 0)

            $0.column(Columns.pendingUnconfirmed.name, .text).defaults(to: "0")
            $0.column(Columns.pendingUnconfirmedAmount.name, .double).defaults(to: 0)

            $0.column(Columns.rewards.name, .text).defaults(to: "0")
            $0.column(Columns.rewardsAmount.name, .double).defaults(to: 0)
            
            $0.column(Columns.reserved.name, .text).defaults(to: "0")
            $0.column(Columns.reservedAmount.name, .double).defaults(to: 0)
            
            $0.column(Columns.withdrawable.name, .text).defaults(to: "0")
            $0.column(Columns.withdrawableAmount.name, .double).defaults(to: 0)
            
            $0.column(sql: totalAmountSQlCreation)
            
            $0.column(Columns.isEnabled.name, .boolean).defaults(to: true).indexed()
            $0.column(Columns.isPinned.name, .boolean).defaults(to: false).indexed()
            $0.column(Columns.isActive.name, .boolean).defaults(to: true).indexed()
            
            $0.column(Columns.metadata.name, .jsonText)
            $0.column(Columns.lastUsedAt.name, .date)
            $0.column(Columns.updatedAt.name, .date)
            $0.uniqueKey([
                Columns.assetId.name,
                Columns.walletId.name,
            ])
        }
    }
    
    static let totalAmountSQlCreation = "totalAmount DOUBLE AS (availableAmount + frozenAmount + lockedAmount + stakedAmount + pendingAmount + rewardsAmount)"
}

extension BalanceRecord: Identifiable {
    public var id: String { assetId.identifier }
}

extension BalanceRecord {
    func mapToBalance() -> Balance {
        return Balance(
            available: BigInt(stringLiteral: available),
            frozen: BigInt(stringLiteral: frozen),
            locked: BigInt(stringLiteral: locked),
            staked: BigInt(stringLiteral: staked),
            pending: BigInt(stringLiteral: pending),
            pendingUnconfirmed: BigInt(stringLiteral: pendingUnconfirmed),
            rewards: BigInt(stringLiteral: rewards),
            reserved: BigInt(stringLiteral: reserved),
            withdrawable: BigInt(stringLiteral: withdrawable),
            yield: BigInt(stringLiteral: yield),
            metadata: metadata
        )
    }
    
    func mapToAssetBalance() -> AssetBalance {
        return AssetBalance(
            assetId: assetId,
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
