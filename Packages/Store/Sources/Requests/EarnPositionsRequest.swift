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
        try StakeDelegationRecord
            .including(optional: StakeDelegationRecord.validator)
            .including(optional: StakeDelegationRecord.price)
            .filter(StakeDelegationRecord.Columns.walletId == walletId.id)
            .filter(StakeDelegationRecord.Columns.assetId == assetId.identifier)
            .order(StakeDelegationRecord.Columns.balance.desc)
            .asRequest(of: StakeDelegationInfo.self)
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
        try EarnPositionRecord
            .filter(EarnPositionRecord.Columns.walletId == walletId.id)
            .filter(EarnPositionRecord.Columns.assetId == assetId.identifier)
            .including(required: EarnPositionRecord.provider)
            .order(EarnPositionRecord.Columns.balance.desc)
            .asRequest(of: EarnPositionInfo.self)
            .fetchAll(db)
            .compactMap { $0.earnPosition }
    }
}
