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
                try perpetual.record.upsert(db)
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
    
    // MARK: - Position Operations
    
    
    public func getPositions(walletId: String) throws -> [PerpetualPosition] {
        try db.read { db in
            try PerpetualPositionRecord
                .filter(PerpetualPositionRecord.Columns.walletId == walletId)
                .order(PerpetualPositionRecord.Columns.updatedAt.desc)
                .fetchAll(db)
                .map { $0.mapToPerpetualPosition() }
        }
    }
    
    
    public func getPositions(walletId: String, provider: PerpetualProvider) throws -> [PerpetualPosition] {
        try db.read { db in
            try PerpetualPositionRecord
                .joining(required: PerpetualPositionRecord.perpetual
                    .filter(PerpetualRecord.Columns.provider == provider.rawValue)
                )
                .filter(PerpetualPositionRecord.Columns.walletId == walletId)
                .order(PerpetualPositionRecord.Columns.updatedAt.desc)
                .fetchAll(db)
                .map { $0.mapToPerpetualPosition() }
        }
    }
    
    public func diffPositions(deleteIds: [String], positions: [PerpetualPosition], walletId: String) throws {
        if deleteIds.isEmpty && positions.isEmpty {
            return
        }
        try db.write { db in
            try PerpetualPositionRecord
                .filter(deleteIds.contains(PerpetualPositionRecord.Columns.id))
                .deleteAll(db)
            
            for position in positions {
                try position.record(walletId: walletId).upsert(db)
            }
        }
    }
}
