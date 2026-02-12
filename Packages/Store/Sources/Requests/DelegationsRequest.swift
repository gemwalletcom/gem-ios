// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Combine
import GRDB
import GRDBQuery
import Primitives

public struct DelegationsRequest: ValueObservationQueryable {
    public static var defaultValue: [Delegation] { [] }

    private let walletId: WalletId
    private let assetId: AssetId
    private let providerType: EarnProviderType

    public init(walletId: WalletId, assetId: AssetId, providerType: EarnProviderType) {
        self.walletId = walletId
        self.assetId = assetId
        self.providerType = providerType
    }

    public func fetch(_ db: Database) throws -> [Delegation] {
        try StakeDelegationRecord
            .including(optional: StakeDelegationRecord.validator)
            .including(optional: StakeDelegationRecord.price)
            .filter(StakeDelegationRecord.Columns.walletId == walletId.id)
            .filter(StakeDelegationRecord.Columns.assetId == assetId.identifier)
            .joining(required: StakeDelegationRecord.validator
                .filter(StakeValidatorRecord.Columns.providerType == providerType.rawValue))
            .order(StakeDelegationRecord.Columns.balance.desc)
            .asRequest(of: StakeDelegationInfo.self)
            .fetchAll(db)
            .compactMap { $0.mapToDelegation() }
    }
}
