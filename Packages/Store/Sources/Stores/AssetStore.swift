// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct AssetStore: Sendable {
    
    let db: DatabaseQueue

    public init(db: DB) {
        self.db = db.dbQueue
    }
    
    public func insertFull(assets: [AssetFull]) throws {
        try db.write { db in
            for asset in assets {
                try asset.asset.record.insert(db, onConflict: .ignore)
                try AssetRecord
                    .filter(Columns.Asset.id == asset.asset.record.id)
                    .updateAll(db, 
                        Columns.Asset.rank.set(to: asset.score.rank.asInt),
                        Columns.Asset.name.set(to: asset.asset.name),
                        Columns.Asset.symbol.set(to: asset.asset.symbol),
                        Columns.Asset.decimals.set(to: asset.asset.decimals),
                        Columns.Asset.type.set(to: asset.asset.type.rawValue)
                    )
            }
        }
    }
    
    public func getAssets() throws -> [Asset] {
        try db.read { db in
            try AssetRecord
                .fetchAll(db)
                .map { $0.mapToAsset() }
        }
    }
    
    public func getAssets(for assetIds: [String]) throws -> [Asset] {
        try db.read { db in
            try AssetRecord
                .filter(assetIds.contains(Columns.Asset.id))
                .fetchAll(db)
                .map { $0.mapToAsset() }
        }
    }
    
    public func getAssetsData(for walletId: String, filters: [AssetsRequestFilter]) throws -> [AssetData] {
        try db.read { db in
            return try AssetsRequest(walletID: walletId)
                .fetchAssets(filters: filters)
                .fetchAll(db)
                .map { $0.assetData}
        }
    }
    
    @discardableResult
    public func setAssetIsBuyable(for assetIds: [String], value: Bool) throws -> Int {
        try setColumn(for: assetIds, column: Columns.Asset.isBuyable, value: value)
    }
    
    @discardableResult
    public func setAssetIsSwappable(for assetIds: [String], value: Bool) throws -> Int {
        try setColumn(for: assetIds, column: Columns.Asset.isSwappable, value: value)
    }
    
    private func setColumn(for assetIds: [String], column: Column, value: Bool) throws -> Int {
        try db.write { db in
            return try AssetRecord
                .filter(assetIds.contains(Columns.Asset.id))
                .updateAll(db, column.set(to: value))
        }
    }
    
    @discardableResult
    public func clearTokens() throws -> Int {
        try db.write { db in
            try AssetRecord
                .filter(Columns.Asset.type != AssetType.native.rawValue)
                .deleteAll(db)
        }
    }
    
    // Asset Details
    
    public func updateDetails(_ assetsDetails: AssetFull) throws {
        try db.write { db in
            try assetsDetails.record.upsert(db)
            
            var assignments: [ColumnAssignment] = [
                Columns.Asset.rank.set(to: assetsDetails.score.rank),
            ]
            
            if let details = assetsDetails.details {
                assignments.append(contentsOf: [
                    Columns.Asset.rank.set(to: details.isBuyable),
                    Columns.Asset.isBuyable.set(to: details.isBuyable),
                    Columns.Asset.isSellable.set(to: details.isSellable),
                    //Columns.Asset.isSwappable.set(to: details.isSwapable), //TODO: no longer defined by the backend
                    Columns.Asset.isStakeable.set(to: details.isStakeable),
                ])
            }
            
            try AssetRecord
                .filter(Columns.Asset.id == assetsDetails.asset.id.identifier)
                .updateAll(db, assignments)
        }
    }
}
