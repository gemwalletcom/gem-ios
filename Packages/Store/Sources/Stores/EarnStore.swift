// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct EarnStore: Sendable {

    let db: DatabaseQueue

    public init(db: DB) {
        self.db = db.dbQueue
    }

    public func getProviders(chain: Chain) throws -> [EarnProvider] {
        try db.read { db in
            try EarnProviderRecord
                .filter(EarnProviderRecord.Columns.chain == chain.rawValue)
                .fetchAll(db)
                .compactMap { $0.earnProvider }
        }
    }

    public func getProvider(id: String) throws -> EarnProvider? {
        try db.read { db in
            try EarnProviderRecord
                .filter(EarnProviderRecord.Columns.id == id)
                .fetchOne(db)?
                .earnProvider
        }
    }

    public func updateProvider(_ provider: EarnProvider) throws {
        try db.write { db in
            try provider.record().upsert(db)
        }
    }

    public func updateProviders(_ providers: [EarnProvider]) throws {
        try db.write { db in
            for provider in providers {
                try provider.record().upsert(db)
            }
        }
    }

    public func getProviderIds() throws -> Set<String> {
        try db.read { db in
            let ids = try EarnProviderRecord
                .select(EarnProviderRecord.Columns.id)
                .fetchAll(db)
                .map { $0.id }
            return Set(ids)
        }
    }

    public func getPositions(walletId: WalletId, assetId: AssetId) throws -> [EarnPosition] {
        try db.read { db in
            try EarnPositionRecord
                .filter(EarnPositionRecord.Columns.walletId == walletId.id)
                .filter(EarnPositionRecord.Columns.assetId == assetId.identifier)
                .including(required: EarnPositionRecord.provider)
                .asRequest(of: EarnPositionInfo.self)
                .fetchAll(db)
                .compactMap { $0.earnPosition }
        }
    }

    public func getPosition(walletId: WalletId, assetId: AssetId, providerId: String) throws -> EarnPosition? {
        let recordId = EarnProvider.recordId(chain: assetId.chain, providerId: providerId)
        return try db.read { db in
            try EarnPositionRecord
                .filter(EarnPositionRecord.Columns.walletId == walletId.id)
                .filter(EarnPositionRecord.Columns.assetId == assetId.identifier)
                .filter(EarnPositionRecord.Columns.providerId == recordId)
                .including(required: EarnPositionRecord.provider)
                .asRequest(of: EarnPositionInfo.self)
                .fetchOne(db)?
                .earnPosition
        }
    }

    public func updatePosition(_ position: EarnPositionBase, walletId: WalletId) throws {
        let providerIds = try getProviderIds()
        let recordId = EarnProvider.recordId(chain: position.assetId.chain, providerId: position.providerId)
        guard providerIds.contains(recordId) else { return }
        try db.write { db in
            try position.record(walletId: walletId.id).upsert(db)
        }
    }

    public func updatePositions(_ positions: [EarnPositionBase], walletId: WalletId) throws {
        let providerIds = try getProviderIds()
        let validPositions = positions.filter {
            providerIds.contains(EarnProvider.recordId(chain: $0.assetId.chain, providerId: $0.providerId))
        }
        try db.write { db in
            for position in validPositions {
                try position.record(walletId: walletId.id).upsert(db)
            }
        }
    }

    public func deletePosition(walletId: WalletId, assetId: AssetId, providerId: String) throws {
        let recordId = EarnProvider.recordId(chain: assetId.chain, providerId: providerId)
        try db.write { db in
            try EarnPositionRecord
                .filter(EarnPositionRecord.Columns.walletId == walletId.id)
                .filter(EarnPositionRecord.Columns.assetId == assetId.identifier)
                .filter(EarnPositionRecord.Columns.providerId == recordId)
                .deleteAll(db)
        }
    }

    @discardableResult
    public func clear() throws -> Int {
        try db.write { db in
            try EarnProviderRecord.deleteAll(db)
        }
    }
}

public struct EarnPositionInfo: Decodable, FetchableRecord {
    public let position: EarnPositionRecord
    public let provider: EarnProviderRecord

    public var earnPosition: EarnPosition? {
        guard let provider = provider.earnProvider else { return nil }
        return position.earnPosition(provider: provider)
    }
}
