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
        try StakePositionRecord
            .including(optional: StakePositionRecord.validator)
            .including(optional: StakePositionRecord.price)
            .filter(StakePositionRecord.Columns.walletId == walletId.id)
            .filter(StakePositionRecord.Columns.assetId == assetId.identifier)
            .order(StakePositionRecord.Columns.balance.desc)
            .asRequest(of: StakePositionInfo.self)
            .fetchAll(db)
            .compactMap { $0.mapToDelegation() }
    }
}

public struct EarnPositionsRequest: ValueObservationQueryable {
    public static var defaultValue: [EarnPosition] { [] }

    private let walletId: WalletId
    private let assetId: AssetId
    public init(walletId: WalletId, assetId: AssetId) {
        self.walletId = walletId
        self.assetId = assetId
    }

    public func fetch(_ db: Database) throws -> [EarnPosition] {
        var request = EarnPositionRecord
            .filter(EarnPositionRecord.Columns.walletId == walletId.id)

        request = request.filter(EarnPositionRecord.Columns.assetId == assetId.identifier)

        return try request
            .order(EarnPositionRecord.Columns.balance.desc)
            .fetchAll(db)
            .compactMap { $0.earnPosition }
    }
}
