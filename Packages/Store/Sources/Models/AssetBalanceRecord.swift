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
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column("assetId", .text)
                .notNull()
                .references(AssetRecord.databaseTableName, onDelete: .cascade)
            $0.column("walletId", .text)
                .notNull()
                .indexed()
                .references(WalletRecord.databaseTableName, onDelete: .cascade)
            $0.column("available", .text)
                .defaults(to: "0")
            $0.column("frozen", .text)
                .defaults(to: "0")
            $0.column("locked", .text)
                .defaults(to: "0")
            $0.column("staked", .text)
                .defaults(to: "0")
            $0.column("pending", .text)
                .defaults(to: "0")
            $0.column("rewards", .text)
                .defaults(to: "0")
            $0.column("reserved", .text)
                .defaults(to: "0")
            $0.column("isEnabled", .boolean)
                .defaults(to: true)
                .indexed()
            $0.column("isHidden", .boolean)
                .defaults(to: false)
                .indexed()
            $0.column("isPinned", .boolean)
                .defaults(to: false)
            $0.column("total", .numeric)
                .defaults(to: 0)
                .indexed()
            $0.column("fiatValue", .numeric)
                .defaults(to: 0)
                .indexed()
            $0.column("updatedAt", .date)
            $0.uniqueKey(["assetId", "walletId"])
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
