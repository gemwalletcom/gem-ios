// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB

struct StakePositionRecord: Codable, FetchableRecord, PersistableRecord  {
    static let databaseTableName: String = "stake_delegations"
    
    enum Columns {
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

    var id: String
    var assetId: AssetId
    var walletId: String
    var state: DelegationState
    var balance: String
    var shares: String?
    var rewards: String
    var completionDate: Date?
    var delegationId: String
    var validatorId: String
    
    static let validator = belongsTo(StakeValidatorRecord.self, key: "validator")
    static let price = belongsTo(PriceRecord.self, key: "price", using: ForeignKey(["assetId"], to: ["assetId"]))
}

extension StakePositionRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName) {
            $0.column(Columns.id.name, .text)
                .notNull()
            $0.column(Columns.walletId.name, .text)
                .notNull()
                .indexed()
                .references(WalletRecord.databaseTableName, onDelete: .cascade, onUpdate: .cascade)
            $0.column(Columns.assetId.name, .text)
                .notNull()
                .indexed()
                .references(AssetRecord.databaseTableName, onDelete: .cascade, onUpdate: .cascade)
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
    func record(walletId: String) -> StakePositionRecord {
        return StakePositionRecord(
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
