// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct EarnStore: Sendable {

    let db: DatabaseQueue

    public init(db: DB) {
        self.db = db.dbQueue
    }

    public func getPositions(walletId: WalletId, type: EarnTypeRecord? = nil) throws -> [EarnPosition] {
        try db.read { db in
            var request = EarnPositionRecord
                .filter(EarnPositionRecord.Columns.walletId == walletId.id)
            if let type {
                request = request.filter(EarnPositionRecord.Columns.type == type.rawValue)
            }
            return try request.fetchAll(db).compactMap { $0.earnPosition }
        }
    }

    public func getPositions(walletId: WalletId, assetId: AssetId, type: EarnTypeRecord? = nil) throws -> [EarnPosition] {
        try db.read { db in
            var request = EarnPositionRecord
                .filter(EarnPositionRecord.Columns.walletId == walletId.id)
                .filter(EarnPositionRecord.Columns.assetId == assetId.identifier)
            if let type {
                request = request.filter(EarnPositionRecord.Columns.type == type.rawValue)
            }
            return try request.fetchAll(db).compactMap { $0.earnPosition }
        }
    }

    public func getPosition(walletId: WalletId, assetId: AssetId, provider: String) throws -> EarnPosition? {
        try db.read { db in
            try EarnPositionRecord
                .filter(EarnPositionRecord.Columns.walletId == walletId.id)
                .filter(EarnPositionRecord.Columns.assetId == assetId.identifier)
                .filter(EarnPositionRecord.Columns.provider == provider)
                .fetchOne(db)?
                .earnPosition
        }
    }

    public func updatePosition(_ position: EarnPosition) throws {
        try db.write { db in
            try position.record.upsert(db)
        }
    }

    public func updatePositions(_ positions: [EarnPosition]) throws {
        try db.write { db in
            for position in positions {
                try position.record.upsert(db)
            }
        }
    }

    public func updateAndDelete(walletId: WalletId, positions: [EarnPosition], deleteIds: [String]) throws {
        try db.write { db in
            for position in positions {
                try position.record.upsert(db)
            }

            try EarnPositionRecord
                .filter(EarnPositionRecord.Columns.walletId == walletId.id)
                .filter(deleteIds.contains(EarnPositionRecord.Columns.id))
                .deleteAll(db)
        }
    }

    public func deletePosition(walletId: WalletId, assetId: AssetId, provider: String) throws {
        try db.write { db in
            try EarnPositionRecord
                .filter(EarnPositionRecord.Columns.walletId == walletId.id)
                .filter(EarnPositionRecord.Columns.assetId == assetId.identifier)
                .filter(EarnPositionRecord.Columns.provider == provider)
                .deleteAll(db)
        }
    }

    public func deletePositions(walletId: WalletId, type: EarnTypeRecord? = nil) throws {
        try db.write { db in
            var request = EarnPositionRecord
                .filter(EarnPositionRecord.Columns.walletId == walletId.id)
            if let type {
                request = request.filter(EarnPositionRecord.Columns.type == type.rawValue)
            }
            try request.deleteAll(db)
        }
    }

    @discardableResult
    public func deletePositions(walletId: WalletId, ids: [String]) throws -> Int {
        try db.write { db in
            try EarnPositionRecord
                .filter(EarnPositionRecord.Columns.walletId == walletId.id)
                .filter(ids.contains(EarnPositionRecord.Columns.id))
                .deleteAll(db)
        }
    }

    @discardableResult
    public func clear(type: EarnTypeRecord? = nil) throws -> Int {
        try db.write { db in
            if let type {
                return try EarnPositionRecord
                    .filter(EarnPositionRecord.Columns.type == type.rawValue)
                    .deleteAll(db)
            }
            return try EarnPositionRecord.deleteAll(db)
        }
    }

    public func getDelegations(walletId: WalletId, assetId: AssetId) throws -> [Delegation] {
        try db.read { db in
            try EarnPositionRecord
                .including(optional: EarnPositionRecord.validator)
                .including(optional: EarnPositionRecord.price)
                .filter(EarnPositionRecord.Columns.walletId == walletId.id)
                .filter(EarnPositionRecord.Columns.assetId == assetId.identifier)
                .filter(EarnPositionRecord.Columns.type == EarnTypeRecord.stake.rawValue)
                .asRequest(of: EarnPositionInfo.self)
                .fetchAll(db)
                .compactMap { $0.mapToDelegation() }
        }
    }
}

// MARK: - Validators

extension EarnStore {
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
