// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct AssetRequestOptional: ValueObservationQueryable {
    public static var defaultValue: AssetData? = .none

    public var assetId: AssetId?
    private let walletId: WalletId

    public init(
        walletId: WalletId,
        assetId: AssetId?
    ) {
        self.walletId = walletId
        self.assetId = assetId
    }

    public func fetch(_ db: Database) throws -> AssetData? {
        try AssetRecord
            .including(optional: AssetRecord.price)
            .including(optional: AssetRecord.balance)
            .including(optional: AssetRecord.account)
            .including(all: AssetRecord.priceAlerts)
            .joining(optional: AssetRecord.balance.filter(BalanceRecord.Columns.walletId == walletId.id))
            .joining(optional: AssetRecord.account.filter(AccountRecord.Columns.walletId == walletId.id))
            .filter(AssetRecord.Columns.id == assetId?.identifier)
            .asRequest(of: AssetRecordInfo.self)
            .fetchOne(db)
            .map { $0.assetData }
    }
}
