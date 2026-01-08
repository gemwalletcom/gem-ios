// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct StakeDelegationsRequest: ValueObservationQueryable {
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
            .map { $0.mapToDelegation() }
    }
}
