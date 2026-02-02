// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB

public enum EarnTypeRecord: String, Codable, Sendable {
    case stake
    case yield
}

public struct EarnPositionRecord: Codable, FetchableRecord, PersistableRecord {
    public static let databaseTableName: String = "earn_positions"

    public enum Columns {
        static let id = Column("id")
        static let walletId = Column("walletId")
        static let assetId = Column("assetId")
        static let type = Column("type")
        static let balance = Column("balance")
        static let rewards = Column("rewards")
        static let apy = Column("apy")
        static let validatorId = Column("validatorId")
        static let state = Column("state")
        static let completionDate = Column("completionDate")
        static let delegationId = Column("delegationId")
        static let shares = Column("shares")
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
    public var type: EarnTypeRecord
    public var balance: String
    public var rewards: String?
    public var apy: Double?

    public var validatorId: String?
    public var state: DelegationState?
    public var completionDate: Date?
    public var delegationId: String?
    public var shares: String?

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
        type: EarnTypeRecord,
        balance: String,
        rewards: String?,
        apy: Double?,
        validatorId: String?,
        state: DelegationState?,
        completionDate: Date?,
        delegationId: String?,
        shares: String?,
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
        self.type = type
        self.balance = balance
        self.rewards = rewards
        self.apy = apy
        self.validatorId = validatorId
        self.state = state
        self.completionDate = completionDate
        self.delegationId = delegationId
        self.shares = shares
        self.provider = provider
        self.name = name
        self.vaultTokenAddress = vaultTokenAddress
        self.assetTokenAddress = assetTokenAddress
        self.vaultBalanceValue = vaultBalanceValue
        self.assetBalanceValue = assetBalanceValue
    }

    static let wallet = belongsTo(WalletRecord.self, key: "wallet")
    static let asset = belongsTo(AssetRecord.self, key: "asset", using: ForeignKey(["assetId"], to: ["id"]))
    static let validator = belongsTo(StakeValidatorRecord.self, key: "validator", using: ForeignKey(["validatorId"], to: ["id"]))
    static let price = belongsTo(PriceRecord.self, key: "price", using: ForeignKey(["assetId"], to: ["assetId"]))
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
            $0.column(Columns.type.name, .text)
                .notNull()
            $0.column(Columns.balance.name, .text)
                .notNull()
                .defaults(to: "0")
            $0.column(Columns.rewards.name, .text)
            $0.column(Columns.apy.name, .double)
            $0.column(Columns.validatorId.name, .text)
                .indexed()
            $0.column(Columns.state.name, .text)
            $0.column(Columns.completionDate.name, .date)
            $0.column(Columns.delegationId.name, .text)
            $0.column(Columns.shares.name, .text)
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
        let earnType: EarnType
        switch type {
        case .stake:
            guard let validatorId, let state else { return nil }
            earnType = .stake(StakePositionData(
                validatorId: validatorId,
                state: state,
                completionDate: completionDate,
                delegationId: delegationId ?? "",
                shares: shares ?? "0"
            ))
        case .yield:
            guard let provider else { return nil }
            earnType = .yield(YieldPositionData(
                provider: provider,
                name: name ?? "",
                vaultTokenAddress: vaultTokenAddress,
                assetTokenAddress: assetTokenAddress,
                vaultBalanceValue: vaultBalanceValue,
                assetBalanceValue: assetBalanceValue
            ))
        }

        return EarnPosition(
            walletId: walletId,
            assetId: assetId,
            type: earnType,
            balance: balance,
            rewards: rewards,
            apy: apy
        )
    }
}

extension DelegationBase {
    public func toEarnPosition(walletId: String, validatorRecordId: String) -> EarnPosition {
        EarnPosition(
            walletId: walletId,
            assetId: assetId,
            type: .stake(StakePositionData(
                validatorId: validatorRecordId,
                state: state,
                completionDate: completionDate,
                delegationId: delegationId,
                shares: shares
            )),
            balance: balance,
            rewards: rewards,
            apy: nil
        )
    }
}

extension EarnPosition {
    public var record: EarnPositionRecord {
        let recordType: EarnTypeRecord
        var validatorId: String?
        var state: DelegationState?
        var completionDate: Date?
        var delegationId: String?
        var shares: String?
        var provider: String?
        var name: String?
        var vaultTokenAddress: String?
        var assetTokenAddress: String?
        var vaultBalanceValue: String?
        var assetBalanceValue: String?

        switch type {
        case .stake(let data):
            recordType = .stake
            validatorId = data.validatorId
            state = data.state
            completionDate = data.completionDate
            delegationId = data.delegationId
            shares = data.shares
        case .yield(let data):
            recordType = .yield
            provider = data.provider
            name = data.name
            vaultTokenAddress = data.vaultTokenAddress
            assetTokenAddress = data.assetTokenAddress
            vaultBalanceValue = data.vaultBalanceValue
            assetBalanceValue = data.assetBalanceValue
        }

        return EarnPositionRecord(
            id: recordId,
            walletId: walletId,
            assetId: assetId,
            type: recordType,
            balance: balance,
            rewards: rewards,
            apy: apy,
            validatorId: validatorId,
            state: state,
            completionDate: completionDate,
            delegationId: delegationId,
            shares: shares,
            provider: provider,
            name: name,
            vaultTokenAddress: vaultTokenAddress,
            assetTokenAddress: assetTokenAddress,
            vaultBalanceValue: vaultBalanceValue,
            assetBalanceValue: assetBalanceValue
        )
    }

    private var recordId: String {
        switch type {
        case .stake(let data):
            return "\(walletId)-\(assetId.identifier)-\(data.validatorId)-\(data.state.rawValue)-\(data.delegationId)"
        case .yield(let data):
            return "\(walletId)-\(assetId.identifier)-\(data.provider)"
        }
    }
}
