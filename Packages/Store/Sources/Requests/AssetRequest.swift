// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct AssetRequest: ValueObservationQueryable {
    public static var defaultValue: AssetData { AssetData.empty }
    
    public var assetId: String
    private let walletId: String

    public init(
        walletId: String,
        assetId: String
    ) {
        self.walletId = walletId
        self.assetId = assetId
    }

    public func fetch(_ db: Database) throws -> AssetData {
        try AssetRecord
            .including(optional: AssetRecord.price)
            .including(optional: AssetRecord.balance)
            .including(optional: AssetRecord.details)
            .including(optional: AssetRecord.account)
            .including(optional: AssetRecord.priceAlert)
            .joining(optional: AssetRecord.balance.filter(Columns.Balance.walletId == walletId))
            .joining(optional: AssetRecord.account.filter(Columns.Account.walletId == walletId))
            .filter(Columns.Asset.id == assetId)
            .asRequest(of: AssetRecordInfo.self)
            .fetchOne(db)
            .map { $0.assetData } ?? .empty
    }
}

// MARK: - Models Exttensions

//TODO: Find a way to remove .empty

extension AssetData {
    public static let empty: AssetData = {
        return AssetData(
            asset: Asset(id: .init(chain: .bitcoin, tokenId: .none), name: "", symbol: "", decimals: 0, type: .native),
            balance: Balance.zero,
            account: Account(chain: .bitcoin, address: "", derivationPath: "", extendedPublicKey: .none),
            price: .none,
            price_alert: .none,
            details: .none,
            metadata: AssetMetaData(
                isEnabled: false,
                isBuyEnabled: false,
                isSwapEnabled: false,
                isStakeEnabled: false,
                isPinned: false
            )
        )
    }()
}
