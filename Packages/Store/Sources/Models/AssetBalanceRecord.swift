// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB
import BigInt

public struct AssetBalanceRecord: Codable, FetchableRecord, PersistableRecord  {
    
    public static var databaseTableName: String = "balances"

    public var assetId: String
    public var walletId: String
    
    public var available: String
    public var frozen: String
    public var locked: String
    public var staked: String
    public var pending: String
    public var rewards: String
    public var reserved: String
    
    public var isEnabled: Bool
    public var isHidden: Bool
    public var isPinned: Bool

    public var total: Double
    public var fiatValue: Double
    
    public var updatedAt: Date?
}

extension AssetBalanceRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName) { t in
            t.column("assetId", .text)
                .notNull()
                .references(AssetRecord.databaseTableName, onDelete: .cascade)
            t.column("walletId", .text)
                .notNull()
                .indexed()
                .references(WalletRecord.databaseTableName, onDelete: .cascade)
            t.column("available", .text)
            t.column("frozen", .text)
            t.column("locked", .text)
            t.column("staked", .text)
            t.column("pending", .text)
            t.column("rewards", .text)
            t.column("reserved", .text)
            t.column("isEnabled", .boolean)
                .defaults(to: true)
                .indexed()
            t.column("isHidden", .boolean)
                .defaults(to: true)
                .indexed()
            t.column("isPinned", .boolean)
                .defaults(to: false)
            t.column("total", .numeric)
                .defaults(to: 0)
                .indexed()
            t.column("fiatValue", .numeric)
                .defaults(to: 0)
                .indexed()
            t.column("updatedAt", .date)
            t.uniqueKey(["assetId", "walletId"])
        }
    }
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
            assetId: AssetId(id: assetId)!,
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
