// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct PriceAlertStore: Sendable {

    let db: DatabaseQueue

    public init(db: DB) {
        self.db = db.dbQueue
    }

    public func getPriceAlerts() throws -> [PriceAlert] {
        try db.read { db in
            try PriceAlertRecord
                .fetchAll(db)
                .map { $0.map() }
        }
    }
    
    public func getPriceAlerts(for assetId: String) throws -> [PriceAlert] {
        try db.read { db in
            try PriceAlertRecord
                .filter(PriceAlertRecord.Columns.assetId == assetId)
                .fetchAll(db)
                .map { $0.map() }
        }
    }

    public func addPriceAlerts(_ alerts: [PriceAlert]) throws {
        try db.write { (db: Database) in
            for alert in alerts {
                try alert
                    .mapToRecord()
                    .upsert(db)
            }
        }
    }

    @discardableResult
    public func deletePriceAlerts(_ alertsIds: [String]) throws -> Int {
        try db.write { (db: Database) in
            try PriceAlertRecord
                .filter(alertsIds.contains(PriceAlertRecord.Columns.id))
                .deleteAll(db)
        }
    }
    
    public func diffPriceAlerts(deleteIds: [String], alerts: [PriceAlert]) throws {
        if deleteIds.isEmpty && alerts.isEmpty {
            return
        }
        try db.write { (db: Database) in
            try PriceAlertRecord
                .filter(deleteIds.contains(PriceAlertRecord.Columns.id))
                .deleteAll(db)
            
            for alert in alerts {
                try alert
                    .mapToRecord()
                    .upsert(db)
            }
        }
    }

    public func clear() throws -> Int {
        try db.write {
            try PriceAlertRecord
                .deleteAll($0)
        }
    }
}
