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
        static let name = Column("name")
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
    public var name: String?
    public var vaultTokenAddress: String?
    public var assetTokenAddress: String?
    public var vaultBalanceValue: String?
    public var assetBalanceValue: String?

    public init(
        id: String,
        walletId: String,
        assetId: AssetId,
        balance: String,
        rewards: String?,
        apy: Double?,
        provider: String?,
        name: String?,
        vaultTokenAddress: String?,
        assetTokenAddress: String?,
        vaultBalanceValue: String?,
        assetBalanceValue: String?
    ) {
        self.id = id
        self.walletId = walletId
        self.assetId = assetId
        self.balance = balance
        self.rewards = rewards
        self.apy = apy
        self.provider = provider
        self.name = name
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
            $0.column(Columns.name.name, .text)
            $0.column(Columns.vaultTokenAddress.name, .text)
            $0.column(Columns.assetTokenAddress.name, .text)
            $0.column(Columns.vaultBalanceValue.name, .text)
            $0.column(Columns.assetBalanceValue.name, .text)
        }
    }
}

extension EarnPositionRecord {
    public var earnPosition: EarnPosition? {
        guard let provider else { return nil }

        return EarnPosition(
            walletId: walletId,
            assetId: assetId,
            type: .yield(EarnPositionData(
                provider: provider,
                name: name ?? "",
                vaultTokenAddress: vaultTokenAddress,
                assetTokenAddress: assetTokenAddress,
                vaultBalanceValue: vaultBalanceValue,
                assetBalanceValue: assetBalanceValue
            )),
            balance: balance,
            rewards: rewards,
            apy: apy
        )
    }
}

extension EarnPosition {
    public var record: EarnPositionRecord {
        guard case .yield(let data) = type else {
            preconditionFailure("Stake positions should be stored in StakeDelegationRecord.")
        }

        return EarnPositionRecord(
            id: recordId,
            walletId: walletId,
            assetId: assetId,
            balance: balance,
            rewards: rewards,
            apy: apy,
            provider: data.provider,
            name: data.name,
            vaultTokenAddress: data.vaultTokenAddress,
            assetTokenAddress: data.assetTokenAddress,
            vaultBalanceValue: data.vaultBalanceValue,
            assetBalanceValue: data.assetBalanceValue
        )
    }

    private var recordId: String {
        guard case .yield(let data) = type else {
            preconditionFailure("Stake positions should be stored in StakeDelegationRecord.")
        }
        return "\(walletId)-\(assetId.identifier)-\(data.provider)"
    }
}
