// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
@preconcurrency import GRDB

public struct StakeDelegationRecord: Codable, FetchableRecord, PersistableRecord  {
    
    public static let databaseTableName: String = "stake_delegations"

    public var id: String
    public var assetId: String
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
            $0.column("id", .text)
                .notNull()
            $0.column("walletId", .text)
                .notNull()
                .indexed()
                .references(WalletRecord.databaseTableName, onDelete: .cascade)
            $0.column("assetId", .text)
                .notNull()
                .indexed()
                .references(AssetRecord.databaseTableName, onDelete: .cascade)
            $0.column("validatorId", .text)
                .notNull()
                .indexed()
                .references(StakeValidatorRecord.databaseTableName, onDelete: .cascade)
            $0.column("state", .text)
                .notNull()
            $0.column("balance", .text)
                .notNull()
                .defaults(to: "0")
            $0.column("shares", .text)
                .notNull()
                .defaults(to: "0")
            $0.column("rewards", .text)
                .notNull()
                .defaults(to: "0")
            $0.column("completionDate", .date)
            $0.column("delegationId", .text)
                .notNull()
            $0.uniqueKey(["walletId", "assetId", "validatorId", "state", "delegationId"])
        }
    }
}

extension DelegationBase {
    func record(walletId: String) -> StakeDelegationRecord {
        return StakeDelegationRecord(
            id: id,
            assetId: assetId.identifier,
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
