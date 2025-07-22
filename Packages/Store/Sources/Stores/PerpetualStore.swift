// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct PerpetualStore: Sendable {
    let db: DatabaseQueue
    
    public init(db: DB) {
        self.db = db.dbQueue
    }
    
    public func addPerpetuals(_ perpetuals: [Perpetual]) throws {
        try db.write { db in
            for perpetual in perpetuals {
                try perpetual.record.insert(db)
            }
        }
    }
    
    public func upsertPerpetuals(_ perpetuals: [Perpetual]) throws {
        try db.write { db in
            for perpetual in perpetuals {
                try perpetual.record.upsert(db)
            }
        }
    }
    
    public func getPerpetual(id: String) throws -> Perpetual? {
        try db.read { db in
            try PerpetualRecord
                .filter(PerpetualRecord.Columns.id == id)
                .fetchOne(db)?
                .mapToPerpetual()
        }
    }
    
    public func getPerpetuals() throws -> [Perpetual] {
        try db.read { db in
            try PerpetualRecord
                .fetchAll(db)
                .compactMap { try $0.mapToPerpetual() }
        }
    }
    
    // MARK: - Position Operations
    
    public func addPositions(_ positions: [PerpetualPosition], walletId: String) throws {
        try db.write { db in
            for position in positions {
                try position.record(walletId: walletId).insert(db)
            }
        }
    }
    
    public func upsertPositions(_ positions: [PerpetualPosition], walletId: String) throws {
        try db.write { db in
            for position in positions {
                try position.record(walletId: walletId).upsert(db)
            }
        }
    }
    
    public func getPosition(id: String) throws -> PerpetualPosition? {
        try db.read { db in
            try PerpetualPositionRecord
                .including(required: PerpetualPositionRecord.perpetual)
                .filter(PerpetualPositionRecord.Columns.id == id)
                .asRequest(of: PositionInfo.self)
                .fetchOne(db)?
                .mapToPerpetualPosition()
        }
    }
    
    public func getPositions(walletId: String) throws -> [PerpetualPosition] {
        try db.read { db in
            try PerpetualPositionRecord
                .including(required: PerpetualPositionRecord.perpetual)
                .filter(PerpetualPositionRecord.Columns.walletId == walletId)
                .order(PerpetualPositionRecord.Columns.updatedAt.desc)
                .asRequest(of: PositionInfo.self)
                .fetchAll(db)
                .compactMap { try $0.mapToPerpetualPosition() }
        }
    }
    
    public func deletePositions(ids: [String]) throws {
        try db.write { db in
            for id in ids {
                try PerpetualPositionRecord.deleteOne(db, key: id)
            }
        }
    }
}
