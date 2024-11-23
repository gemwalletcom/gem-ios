// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct AssetStore: Sendable {
    
    let db: DatabaseQueue

    public init(db: DB) {
        self.db = db.dbQueue
    }
    
    public func add(assets: [AssetBasic]) throws {
        try db.write { db in
            for asset in assets {
                try asset.asset.record.insert(db, onConflict: .ignore)
                try AssetRecord
                    .filter(Columns.Asset.id == asset.asset.id.identifier)
                    .updateAll(db,
                        Columns.Asset.rank.set(to: asset.score.rank.asInt),
                        Columns.Asset.name.set(to: asset.asset.name),
                        Columns.Asset.symbol.set(to: asset.asset.symbol),
                        Columns.Asset.decimals.set(to: asset.asset.decimals),
                        Columns.Asset.type.set(to: asset.asset.type.rawValue),
                               
                        Columns.Asset.isBuyable.set(to: asset.properties.isBuyable),
                        Columns.Asset.isSellable.set(to: asset.properties.isSellable),
                        Columns.Asset.isSwappable.set(to: asset.properties.isSwapable),
                        Columns.Asset.isStakeable.set(to: asset.properties.isStakeable),
                        Columns.Asset.stakingApr.set(to: asset.properties.stakingApr)
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
    public func setAssetIsSellable(for assetIds: [String], value: Bool) throws -> Int {
        try setColumn(for: assetIds, column: Columns.Asset.isSellable, value: value)
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
    
    public func updateLinks(assetId: String, _ links: [AssetLink]) throws {
        try db.write { db in
            for link in links {
                try link.record(assetId: assetId).upsert(db)
            }
        }
    }
}
