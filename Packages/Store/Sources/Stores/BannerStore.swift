// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct BannerStore: Sendable {

    let db: DatabaseQueue
    
    public init(db: DB) {
        self.db = db.dbQueue
    }

    public func addBanners(_ banners: [NewBanner]) throws {
        try db.write { db in
            for banner in banners {
                try banner.record.insert(db, onConflict: .ignore)
            }
        }
    }

    public func updateState(_ id: String, state: BannerState) throws -> Int {
        try db.write {
            try BannerRecord
                .filter(BannerRecord.Columns.id == id)
                .updateAll($0, [BannerRecord.Columns.state.set(to: state.rawValue)])
        }
    }

    public func updateStates(from: BannerState, to: BannerState) throws -> Int {
        try db.write {
            try BannerRecord
                .filter(BannerRecord.Columns.state == from.rawValue)
                .updateAll($0, [BannerRecord.Columns.state.set(to: to.rawValue)])
        }
    }

    public func clear() throws -> Int {
        try db.write {
            try BannerRecord
                .deleteAll($0)
        }
    }

    public func getBanner(id: String) throws -> BannerRecord? {
        try db.read {
            try BannerRecord
                .filter(BannerRecord.Columns.id == id)
                .fetchOne($0)
        }
    }
}
