// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct PerpetualStore: Sendable {
    let db: DatabaseQueue
    
    public init(db: DB) {
        self.db = db.dbQueue
    }
    
    
    public func upsertPerpetuals(_ perpetuals: [Perpetual]) throws {
        try db.write { db in
            for perpetual in perpetuals {
                try perpetual.record.insert(db, onConflict: .ignore)
                try PerpetualRecord
                    .filter(PerpetualRecord.Columns.id == perpetual.id)
                    .updateAll(
                        db,
                        PerpetualRecord.Columns.price.set(to: perpetual.price),
                        PerpetualRecord.Columns.pricePercentChange24h.set(to: perpetual.pricePercentChange24h),
                        PerpetualRecord.Columns.openInterest.set(to: perpetual.openInterest),
                        PerpetualRecord.Columns.volume24h.set(to: perpetual.volume24h),
                        PerpetualRecord.Columns.funding.set(to: perpetual.funding),
                        PerpetualRecord.Columns.maxLeverage.set(to: perpetual.maxLeverage)
                    )
            }
        }
    }
    
    
    public func getPerpetuals() throws -> [Perpetual] {
        try db.read { db in
            try PerpetualRecord
                .fetchAll(db)
                .map { $0.mapToPerpetual() }
        }
    }
    
    public func getPositions(walletId: WalletId) throws -> [PerpetualPosition] {
        try db.read { db in
            try PerpetualPositionRecord
                .filter(PerpetualPositionRecord.Columns.walletId == walletId.id)
                .order(PerpetualPositionRecord.Columns.updatedAt.desc)
                .fetchAll(db)
                .map { $0.mapToPerpetualPosition() }
        }
    }

    public func getPositions(walletId: WalletId, provider: PerpetualProvider) throws -> [PerpetualPosition] {
        try db.read { db in
            try PerpetualPositionRecord
                .joining(required: PerpetualPositionRecord.perpetual
                    .filter(PerpetualRecord.Columns.provider == provider.rawValue)
                )
                .filter(PerpetualPositionRecord.Columns.walletId == walletId.id)
                .order(PerpetualPositionRecord.Columns.updatedAt.desc)
                .fetchAll(db)
                .map { $0.mapToPerpetualPosition() }
        }
    }

    public func diffPositions(deleteIds: [String], positions: [PerpetualPosition], walletId: WalletId) throws {
        if deleteIds.isEmpty && positions.isEmpty {
            return
        }
        try db.write { db in
            try PerpetualPositionRecord
                .filter(deleteIds.contains(PerpetualPositionRecord.Columns.id))
                .deleteAll(db)

            for position in positions {
                try position.record(walletId: walletId.id).upsert(db)
            }
        }
    }
    
    @discardableResult
    public func setPinned(for perpetualIds: [String], value: Bool) throws -> Int {
        try setColumn(for: perpetualIds, column: PerpetualRecord.Columns.isPinned, value: value)
    }
    
    private func setColumn(for perpetualIds: [String], column: Column, value: Bool) throws -> Int {
        try db.write { db in
            return try PerpetualRecord
                .filter(perpetualIds.contains(PerpetualRecord.Columns.id))
                .updateAll(db, column.set(to: value))
        }
    }
    
    public func clear() throws {
        try db.write { db in
            try PerpetualPositionRecord.deleteAll(db)
            try PerpetualRecord.deleteAll(db)
            // SearchRecords with perpetualId are deleted via cascade
        }
    }
}
