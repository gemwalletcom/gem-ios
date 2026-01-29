// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Combine
import GRDB
import GRDBQuery
import Primitives

public struct EarnDelegationsRequest: ValueObservationQueryable {
    public static var defaultValue: [Delegation] { [] }

    private let walletId: WalletId
    private let assetId: AssetId

    public init(walletId: WalletId, assetId: AssetId) {
        self.walletId = walletId
        self.assetId = assetId
    }

    public func fetch(_ db: Database) throws -> [Delegation] {
        try EarnPositionRecord
            .including(optional: EarnPositionRecord.validator)
            .including(optional: EarnPositionRecord.price)
            .filter(EarnPositionRecord.Columns.walletId == walletId.id)
            .filter(EarnPositionRecord.Columns.assetId == assetId.identifier)
            .filter(EarnPositionRecord.Columns.type == EarnType.stake.rawValue)
            .order(EarnPositionRecord.Columns.balance.desc)
            .asRequest(of: EarnPositionInfo.self)
            .fetchAll(db)
            .compactMap { $0.mapToDelegation() }
    }
}

public struct EarnPositionsRequest: ValueObservationQueryable {
    public static var defaultValue: [EarnPosition] { [] }

    private let walletId: WalletId
    private let assetId: AssetId?
    private let type: EarnType?

    public init(walletId: WalletId, assetId: AssetId? = nil, type: EarnType? = nil) {
        self.walletId = walletId
        self.assetId = assetId
        self.type = type
    }

    public func fetch(_ db: Database) throws -> [EarnPosition] {
        var request = EarnPositionRecord
            .filter(EarnPositionRecord.Columns.walletId == walletId.id)

        if let assetId {
            request = request.filter(EarnPositionRecord.Columns.assetId == assetId.identifier)
        }

        if let type {
            request = request.filter(EarnPositionRecord.Columns.type == type.rawValue)
        }

        return try request
            .order(EarnPositionRecord.Columns.balance.desc)
            .fetchAll(db)
            .map { $0.earnPosition }
    }
}
