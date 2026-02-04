// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB

public struct EarnPositionRecord: Codable, FetchableRecord, PersistableRecord {
    public static let databaseTableName: String = "earn_positions"

    public enum Columns {
        static let id = Column("id")
        static let walletId = Column("walletId")
        static let assetId = Column("assetId")
        static let balance = Column("balance")
        static let rewards = Column("rewards")
        static let apy = Column("apy")
        static let provider = Column("provider")
        static let vaultTokenAddress = Column("vaultTokenAddress")
        static let assetTokenAddress = Column("assetTokenAddress")
        static let vaultBalanceValue = Column("vaultBalanceValue")
        static let assetBalanceValue = Column("assetBalanceValue")
    }

    public var id: String
    public var walletId: String
    public var assetId: AssetId
    public var balance: String
    public var rewards: String?
    public var apy: Double?

    public var provider: String?
    public var vaultTokenAddress: String
    public var assetTokenAddress: String
    public var vaultBalanceValue: String
    public var assetBalanceValue: String

    public init(
        id: String,
        walletId: String,
        assetId: AssetId,
        balance: String,
        rewards: String?,
        apy: Double?,
        provider: String?,
        vaultTokenAddress: String,
        assetTokenAddress: String,
        vaultBalanceValue: String,
        assetBalanceValue: String
    ) {
        self.id = id
        self.walletId = walletId
        self.assetId = assetId
        self.balance = balance
        self.rewards = rewards
        self.apy = apy
        self.provider = provider
        self.vaultTokenAddress = vaultTokenAddress
        self.assetTokenAddress = assetTokenAddress
        self.vaultBalanceValue = vaultBalanceValue
        self.assetBalanceValue = assetBalanceValue
    }

    static let wallet = belongsTo(WalletRecord.self, key: "wallet")
    static let asset = belongsTo(AssetRecord.self, key: "asset", using: ForeignKey(["assetId"], to: ["id"]))
}

extension EarnPositionRecord: CreateTable {
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
            $0.column(Columns.balance.name, .text)
                .notNull()
                .defaults(to: "0")
            $0.column(Columns.rewards.name, .text)
            $0.column(Columns.apy.name, .double)
            $0.column(Columns.provider.name, .text)
            $0.column(Columns.vaultTokenAddress.name, .text)
                .notNull()
                .defaults(to: "")
            $0.column(Columns.assetTokenAddress.name, .text)
                .notNull()
                .defaults(to: "")
            $0.column(Columns.vaultBalanceValue.name, .text)
                .notNull()
                .defaults(to: "0")
            $0.column(Columns.assetBalanceValue.name, .text)
                .notNull()
                .defaults(to: "0")
        }
    }
}

extension EarnPositionRecord {
    public var earnPosition: EarnPosition? {
        guard let provider, let earnProvider = EarnProvider(rawValue: provider) else { return nil }

        return EarnPosition(
            assetId: assetId,
            provider: earnProvider,
            vaultTokenAddress: vaultTokenAddress,
            assetTokenAddress: assetTokenAddress,
            vaultBalanceValue: vaultBalanceValue,
            assetBalanceValue: assetBalanceValue,
            balance: balance,
            rewards: rewards,
            apy: apy
        )
    }
}

extension EarnPosition {
    public func record(walletId: String) -> EarnPositionRecord {
        return EarnPositionRecord(
            id: recordId(walletId: walletId),
            walletId: walletId,
            assetId: assetId,
            balance: balance,
            rewards: rewards,
            apy: apy,
            provider: provider.rawValue,
            vaultTokenAddress: vaultTokenAddress,
            assetTokenAddress: assetTokenAddress,
            vaultBalanceValue: vaultBalanceValue,
            assetBalanceValue: assetBalanceValue
        )
    }

    private func recordId(walletId: String) -> String {
        "\(walletId)-\(assetId.identifier)-\(provider.rawValue)"
    }
}
