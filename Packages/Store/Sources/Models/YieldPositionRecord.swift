// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB

public struct YieldPositionRecord: Codable, FetchableRecord, PersistableRecord {
    public static let databaseTableName: String = "yield_positions"

    public enum Columns {
        static let id = Column("id")
        static let walletId = Column("walletId")
        static let assetId = Column("assetId")
        static let provider = Column("provider")
        static let name = Column("name")
        static let vaultTokenAddress = Column("vaultTokenAddress")
        static let assetTokenAddress = Column("assetTokenAddress")
        static let vaultBalanceValue = Column("vaultBalanceValue")
        static let assetBalanceValue = Column("assetBalanceValue")
        static let apy = Column("apy")
        static let rewards = Column("rewards")
    }

    public var id: String
    public var walletId: String
    public var assetId: AssetId
    public var provider: String
    public var name: String
    public var vaultTokenAddress: String
    public var assetTokenAddress: String
    public var vaultBalanceValue: String?
    public var assetBalanceValue: String?
    public var apy: Double?
    public var rewards: String?

    public init(
        id: String,
        walletId: String,
        assetId: AssetId,
        provider: String,
        name: String,
        vaultTokenAddress: String,
        assetTokenAddress: String,
        vaultBalanceValue: String?,
        assetBalanceValue: String?,
        apy: Double?,
        rewards: String?
    ) {
        self.id = id
        self.walletId = walletId
        self.assetId = assetId
        self.provider = provider
        self.name = name
        self.vaultTokenAddress = vaultTokenAddress
        self.assetTokenAddress = assetTokenAddress
        self.vaultBalanceValue = vaultBalanceValue
        self.assetBalanceValue = assetBalanceValue
        self.apy = apy
        self.rewards = rewards
    }

    static let wallet = belongsTo(WalletRecord.self, key: "wallet")
    static let asset = belongsTo(AssetRecord.self, key: "asset", using: ForeignKey(["assetId"], to: ["id"]))
}

extension YieldPositionRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.primaryKey(Columns.id.name, .text)
                .notNull()
            $0.column(Columns.walletId.name, .text)
                .notNull()
                .indexed()
                .references(WalletRecord.databaseTableName, onDelete: .cascade, onUpdate: .cascade)
            $0.column(Columns.assetId.name, .text)
                .notNull()
                .indexed()
                .references(AssetRecord.databaseTableName, onDelete: .cascade, onUpdate: .cascade)
            $0.column(Columns.provider.name, .text)
                .notNull()
            $0.column(Columns.name.name, .text)
                .notNull()
            $0.column(Columns.vaultTokenAddress.name, .text)
                .notNull()
            $0.column(Columns.assetTokenAddress.name, .text)
                .notNull()
            $0.column(Columns.vaultBalanceValue.name, .text)
            $0.column(Columns.assetBalanceValue.name, .text)
            $0.column(Columns.apy.name, .double)
            $0.column(Columns.rewards.name, .text)
            $0.uniqueKey([
                Columns.walletId.name,
                Columns.assetId.name,
                Columns.provider.name
            ])
        }
    }
}
