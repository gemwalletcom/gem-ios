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
    private let providerType: GrowthProviderType?

    public init(walletId: WalletId, assetId: AssetId, providerType: GrowthProviderType? = nil) {
        self.walletId = walletId
        self.assetId = assetId
        self.providerType = providerType
    }

    public func fetch(_ db: Database) throws -> [Delegation] {
        var request = StakeDelegationRecord
            .including(optional: StakeDelegationRecord.validator)
            .including(optional: StakeDelegationRecord.price)
            .filter(StakeDelegationRecord.Columns.walletId == walletId.id)
            .filter(StakeDelegationRecord.Columns.assetId == assetId.identifier)

        if let providerType {
            request = request.joining(required: StakeDelegationRecord.validator
                .filter(StakeValidatorRecord.Columns.providerType == providerType.rawValue))
        }

        return try request
            .order(StakeDelegationRecord.Columns.balance.desc)
            .asRequest(of: StakeDelegationInfo.self)
            .fetchAll(db)
            .compactMap { $0.mapToDelegation() }
    }
}
