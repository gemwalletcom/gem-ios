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

    public func addPriceAlerts(_ alerts: [PriceAlert]) throws {
        try db.write { (db: Database) in
            for alert in alerts {
                try alert
                    .mapToRecord()
                    .insert(db, onConflict: .ignore)
            }
        }
    }

    public func deletePriceAlerts(_ alerts: [PriceAlert]) throws {
        try db.write { (db: Database) in
            for alert in alerts {
                try alert.mapToRecord().delete(db)
            }
        }
    }
    
    public func deleteAll(for assetId: String) throws {
        let _ = try db.write { db in
            try PriceAlertRecord
                .filter(Columns.PriceAlert.assetId == assetId)
                .deleteAll(db)
        }
    }

    public func clear() throws -> Int {
        try db.write {
            try PriceAlertRecord
                .deleteAll($0)
        }
    }
}
