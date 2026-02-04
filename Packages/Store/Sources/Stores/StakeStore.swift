// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct StakeStore: Sendable {

    let db: DatabaseQueue

    public init(db: DB) {
        self.db = db.dbQueue
    }

    public func getDelegations(walletId: WalletId, assetId: AssetId) throws -> [Delegation] {
        try db.read { db in
            try StakeDelegationRecord
                .including(optional: StakeDelegationRecord.validator)
                .including(optional: StakeDelegationRecord.price)
                .filter(StakeDelegationRecord.Columns.walletId == walletId.id)
                .filter(StakeDelegationRecord.Columns.assetId == assetId.identifier)
                .order(StakeDelegationRecord.Columns.balance.desc)
                .asRequest(of: StakeDelegationInfo.self)
                .fetchAll(db)
                .compactMap { $0.mapToDelegation() }
        }
    }

    public func getDelegationIds(walletId: WalletId, assetId: AssetId) throws -> [String] {
        try db.read { db in
            try StakeDelegationRecord
                .filter(StakeDelegationRecord.Columns.walletId == walletId.id)
                .filter(StakeDelegationRecord.Columns.assetId == assetId.identifier)
                .fetchAll(db)
                .map(\.id)
        }
    }

    public func updateAndDelete(walletId: WalletId, delegations: [DelegationBase], deleteIds: [String]) throws {
        try db.write { db in
            for delegation in delegations {
                try delegation.record(walletId: walletId.id).upsert(db)
            }

            try StakeDelegationRecord
                .filter(StakeDelegationRecord.Columns.walletId == walletId.id)
                .filter(deleteIds.contains(StakeDelegationRecord.Columns.id))
                .deleteAll(db)
        }
    }

    @discardableResult
    public func clearDelegations() throws -> Int {
        try db.write { db in
            try StakeDelegationRecord.deleteAll(db)
        }
    }
}

// MARK: - Validators

extension StakeStore {
    public func getStakeApr(assetId: AssetId) throws -> Double? {
        try db.read { db in
            try AssetRecord
                .filter(key: assetId.identifier)
                .fetchOne(db)
                .map { $0.stakingApr } ?? .none
        }
    }

    public func getValidator(assetId: AssetId, validatorId: String) throws -> DelegationValidator? {
        try db.read { db in
            try StakeValidatorRecord
                .filter(StakeValidatorRecord.Columns.assetId == assetId.identifier)
                .filter(StakeValidatorRecord.Columns.validatorId == validatorId)
                .fetchOne(db)
                .map { $0.validator }
        }
    }

    public func getValidators(assetId: AssetId) throws -> [DelegationValidator] {
        try db.read { db in
            try StakeValidatorRecord
                .filter(StakeValidatorRecord.Columns.assetId == assetId.identifier)
                .order(StakeValidatorRecord.Columns.apr.desc)
                .fetchAll(db)
                .map { $0.validator }
        }
    }

    public func getValidatorsActive(assetId: AssetId) throws -> [DelegationValidator] {
        try db.read { db in
            try Self.getValidatorsActive(db: db, assetId: assetId)
        }
    }

    public func updateValidators(_ validators: [DelegationValidator]) throws {
        try db.write { db in
            for validator in validators {
                try validator.record.upsert(db)
            }
        }
    }

    @discardableResult
    public func clearValidators() throws -> Int {
        try db.write { db in
            try StakeValidatorRecord.deleteAll(db)
        }
    }

    public static func getValidatorsActive(db: Database, assetId: AssetId) throws -> [DelegationValidator] {
        let excludeValidatorIds = [DelegationValidator.systemId, DelegationValidator.legacySystemId]
        return try StakeValidatorRecord
            .filter(StakeValidatorRecord.Columns.assetId == assetId.identifier)
            .filter(StakeValidatorRecord.Columns.isActive == true)
            .filter(!excludeValidatorIds.contains(StakeValidatorRecord.Columns.validatorId))
            .filter(StakeValidatorRecord.Columns.name != "")
            .order(StakeValidatorRecord.Columns.apr.desc)
            .fetchAll(db)
            .map { $0.validator }
    }
}
