// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct SearchStore: Sendable {
    private let dbQueue: DatabaseQueue

    public init(db: DB) {
        self.dbQueue = db.dbQueue
    }

    public func add(type: SearchItemType, query: String, ids: [String]) throws {
        switch type {
        case .asset: try addAssets(query: query, ids: ids)
        case .perpetual: try addPerpetuals(query: query, ids: ids)
        case .nft: break
        }
    }

    public func clear() throws {
        _ = try dbQueue.write { try SearchRecord.deleteAll($0) }
    }
}

// MARK: - Private

extension SearchStore {
    private func addAssets(query: String, ids: [String]) throws {
        try dbQueue.write { database in
            try SearchRecord
                .filter(SearchRecord.Columns.query == query)
                .filter(SearchRecord.Columns.assetId != nil)
                .deleteAll(database)
            for (index, id) in ids.enumerated() {
                try SearchRecord(query: query, assetId: id, priority: index).insert(database)
            }
        }
    }

    private func addPerpetuals(query: String, ids: [String]) throws {
        try dbQueue.write { database in
            try SearchRecord
                .filter(SearchRecord.Columns.query == query)
                .filter(SearchRecord.Columns.perpetualId != nil)
                .deleteAll(database)
            for (index, id) in ids.enumerated() {
                try SearchRecord(query: query, perpetualId: id, priority: index).insert(database)
            }
        }
    }
}
