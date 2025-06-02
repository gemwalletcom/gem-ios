// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB

public struct StakeDelegationRecord: Codable, FetchableRecord, PersistableRecord  {
    public static let databaseTableName: String = "stake_delegations"
    
    public enum Columns {
        static let id = Column("id")
        static let walletId = Column("walletId")
        static let assetId = Column("assetId")
        static let validatorId = Column("validatorId")
        static let state = Column("state")
        static let balance = Column("balance")
        static let shares = Column("shares")
        static let rewards = Column("rewards")
        static let completionDate = Column("completionDate")
        static let delegationId = Column("delegationId")
    }

    public var id: String
    public var assetId: AssetId
    public var walletId: String
    public var state: DelegationState
    public var balance: String
    public var shares: String?
    public var rewards: String
    public var completionDate: Date?
    public var delegationId: String
    public var validatorId: String
    
    static let validator = belongsTo(StakeValidatorRecord.self, key: "validator")
    static let price = belongsTo(PriceRecord.self, key: "price", using: ForeignKey(["assetId"], to: ["assetId"]))
}

extension StakeDelegationRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName) {
            $0.column(Columns.id.name, .text)
                .notNull()
            $0.column(Columns.walletId.name, .text)
                .notNull()
                .indexed()
                .references(WalletRecord.databaseTableName, onDelete: .cascade)
            $0.column(Columns.assetId.name, .text)
                .notNull()
                .indexed()
                .references(AssetRecord.databaseTableName, onDelete: .cascade)
            $0.column(Columns.validatorId.name, .text)
                .notNull()
                .indexed()
                .references(StakeValidatorRecord.databaseTableName, onDelete: .cascade)
            $0.column(Columns.state.name, .text)
                .notNull()
            $0.column(Columns.balance.name, .text)
                .notNull()
                .defaults(to: "0")
            $0.column(Columns.shares.name, .text)
                .notNull()
                .defaults(to: "0")
            $0.column(Columns.rewards.name, .text)
                .notNull()
                .defaults(to: "0")
            $0.column(Columns.completionDate.name, .date)
            $0.column(Columns.delegationId.name, .text)
                .notNull()
            $0.uniqueKey([
                Columns.walletId.name,
                Columns.assetId.name,
                Columns.validatorId.name,
                Columns.state.name,
                Columns.delegationId.name
            ])
        }
    }
}

extension DelegationBase {
    func record(walletId: String) -> StakeDelegationRecord {
        return StakeDelegationRecord(
            id: id,
            assetId: assetId,
            walletId: walletId,
            state: state,
            balance: balance,
            shares: shares,
            rewards: rewards,
            completionDate: completionDate,
            delegationId: delegationId,
            validatorId: DelegationValidator.recordId(chain: assetId.chain, validatorId: validatorId)
        )
    }
}
