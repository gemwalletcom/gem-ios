// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct AssetRequest: ValueObservationQueryable {
    public static var defaultValue: AssetData { AssetData.empty }
    
    public var assetId: AssetId
    private let walletId: String

    public init(
        walletId: String,
        assetId: AssetId
    ) {
        self.walletId = walletId
        self.assetId = assetId
    }

    public func fetch(_ db: Database) throws -> AssetData {
        try AssetRecord
            .including(optional: AssetRecord.price)
            .including(optional: AssetRecord.balance)
            .including(optional: AssetRecord.account)
            .including(all: AssetRecord.priceAlerts)
            .joining(optional: AssetRecord.balance.filter(BalanceRecord.Columns.walletId == walletId))
            .joining(optional: AssetRecord.account.filter(AccountRecord.Columns.walletId == walletId))
            .filter(AssetRecord.Columns.id == assetId.identifier)
            .asRequest(of: AssetRecordInfo.self)
            .fetchOne(db)
            .map { $0.assetData } ?? .empty
    }
}

// MARK: - Models Extensions

//TODO: Find a way to remove .empty

extension AssetData {
    public static let empty: AssetData = {
        return AssetData(
            asset: Asset(id: .init(chain: .bitcoin, tokenId: .none), name: "", symbol: "", decimals: 0, type: .native),
            balance: Balance.zero,
            account: Account(
                chain: .bitcoin,
                address: "",
                derivationPath: "",
                extendedPublicKey: .none
            ),
            price: .none,
            priceAlerts: [],
            metadata: AssetMetaData(
                isEnabled: false,
                isBuyEnabled: false,
                isSellEnabled: false,
                isSwapEnabled: false,
                isStakeEnabled: false,
                isPinned: false,
                isActive: true,
                stakingApr: .none,
                rankScore: 0
            )
        )
    }()

    public static func with(asset: Asset) -> AssetData {
        AssetData(
            asset: asset,
            balance: .zero,
            account: Account(
                chain: asset.chain,
                address: .empty,
                derivationPath: .empty,
                extendedPublicKey: .none
            ),
            price: .none,
            priceAlerts: [],
            metadata: AssetMetaData(
                isEnabled: false,
                isBuyEnabled: false,
                isSellEnabled: false,
                isSwapEnabled: false,
                isStakeEnabled: false,
                isPinned: false,
                isActive: true,
                stakingApr: .none,
                rankScore: 0
            )
        )
    }
}
