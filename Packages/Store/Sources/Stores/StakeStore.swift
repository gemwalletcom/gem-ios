// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct StakeStore: Sendable {
    
    let db: DatabaseQueue
    
    public init(db: DB) {
        self.db = db.dbQueue
    }
    
    public func getStakeApr(assetId: AssetId) throws -> Double? {
        try db.read { db in
            try AssetDetailsRecord
                .filter(Columns.AssetDetail.assetId == assetId.identifier)
                .fetchOne(db)
                .map { $0.stakingApr } ?? .none
        }
    }
    
    public func updateDelegations(walletId: String, delegations: [DelegationBase]) throws {
        try db.write { db in
            for delegation in delegations {
                try delegation.record(walletId: walletId).upsert(db)
            }
        }
    }

    public func updateAndDelete(walletId: String, delegations: [DelegationBase], deleteIds: [String]) throws {
        try db.write { db in
            for delegation in delegations {
                try delegation.record(walletId: walletId).upsert(db)
            }

            try StakeDelegationRecord
                .filter(Columns.StakeDelegation.walletId == walletId)
                .filter(deleteIds.contains(Columns.StakeDelegation.id))
                .deleteAll(db)
        }
    }

    public func getValidator(assetId: AssetId, validatorId: String) throws -> DelegationValidator? {
        try db.read { db in
            try StakeValidatorRecord
                .filter(Columns.StakeValidator.assetId == assetId.identifier)
                .filter(Columns.StakeValidator.validatorId == validatorId)
                .fetchOne(db)
                .map { $0.validator }
        }
    }
    
    public func getValidators(assetId: AssetId) throws -> [DelegationValidator] {
        try db.read { db in
            try StakeValidatorRecord
                .filter(Columns.StakeValidator.assetId == assetId.identifier)
                .order(Columns.StakeValidator.apr.desc)
                .fetchAll(db)
                .map { $0.validator }
        }
    }
    
    public func updateValidators(_ validators: [DelegationValidator]) throws {
        try db.write { db in
            for validator in validators {
                try validator.record.upsert(db)
            }
        }
    }
    
    public func getDelegations(walletId: String, assetId: AssetId) throws -> [Delegation] {
        try db.read { db in
            try StakeDelegationRecord
                .including(optional: StakeDelegationRecord.validator)
                .including(optional: StakeDelegationRecord.price)
                .filter(Columns.StakeDelegation.walletId == walletId)
                .filter(Columns.StakeDelegation.assetId == assetId.identifier)
                .asRequest(of: StakeDelegationInfo.self)
                .fetchAll(db)
                .map { $0.mapToDelegation() }
        }
    }
    
    @discardableResult
    public func deleteDelegations(walletId: String, ids: [String]) throws -> Int {
        try db.write { db in
            try StakeDelegationRecord
                .filter(Columns.StakeDelegation.walletId == walletId)
                .filter(ids.contains(Columns.StakeDelegation.id))
                .deleteAll(db)
        }
    }
    
    @discardableResult
    public func clearDelegations() throws -> Int {
        try db.write { db in
            try StakeDelegationRecord.deleteAll(db)
        }
    }
    
    @discardableResult
    public func clearValidators() throws -> Int {
        try db.write { db in
            try StakeValidatorRecord.deleteAll(db)
        }
    }
    
    public func clear() throws {
        try clearDelegations()
        try clearValidators()
    }
}
