// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct StakeDelegationsRequest: ValueObservationQueryable {
    public static var defaultValue: [Delegation] { [] }
    
    private let walletId: String
    private let assetId: String

    public init(walletId: String, assetId: String) {
        self.walletId = walletId
        self.assetId = assetId
    }

    public func fetch(_ db: Database) throws -> [Delegation] {
        try StakeDelegationRecord
            .including(optional: StakeDelegationRecord.validator)
            .including(optional: StakeDelegationRecord.price)
            .filter(StakeDelegationRecord.Columns.walletId == walletId)
            .filter(StakeDelegationRecord.Columns.assetId == assetId)
            .order(StakeDelegationRecord.Columns.balance.desc)
            .asRequest(of: StakeDelegationInfo.self)
            .fetchAll(db)
            .map { $0.mapToDelegation() }
    }
}
