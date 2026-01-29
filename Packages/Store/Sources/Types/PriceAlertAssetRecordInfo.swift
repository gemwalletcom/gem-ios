// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

struct PriceAlertAssetRecordInfo: FetchableRecord, Codable {
    let asset: AssetRecord
    let priceAlerts: [PriceAlertRecord]?
    let price: PriceRecord?
}

extension PriceAlertAssetRecordInfo {
    func mapToEmptyAssetData() -> AssetData {
        AssetData(
            asset: asset.mapToAsset(),
            balance: .zero,
            account: .init(
                chain: asset.chain,
                address: .empty,
                derivationPath: .empty,
                extendedPublicKey: nil
            ),
            price: price?.mapToPrice(),
            priceAlerts: priceAlerts.or([]).compactMap { $0.map() },
            metadata: AssetMetaData(
                isEnabled: true,
                isBalanceEnabled: true,
                isBuyEnabled: asset.isBuyable,
                isSellEnabled: asset.isSellable,
                isSwapEnabled: asset.isSwappable,
                isStakeEnabled: asset.isStakeable,
                stakingApr: asset.stakingApr,
                isEarnEnabled: asset.isEarnable,
                earnApr: nil,
                isPinned: false,
                isActive: false,
                rankScore: asset.rank.asInt32
            ),
            isEarnable: asset.isEarnable
        )
    }
}
