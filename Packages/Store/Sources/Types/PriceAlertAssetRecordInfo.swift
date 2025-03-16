// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

struct PriceAlertAssetRecordInfo: FetchableRecord, Codable {
    let asset: AssetRecord
    let priceAlert: PriceAlertRecord?
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
            price: nil,
            price_alert: priceAlert?.map(),
            metadata: AssetMetaData(
                isEnabled: true,
                isBuyEnabled: asset.isBuyable,
                isSellEnabled: asset.isSellable,
                isSwapEnabled: asset.isSwappable,
                isStakeEnabled: asset.isStakeable,
                isPinned: false,
                isActive: false,
                stakingApr: asset.stakingApr
            )
        )
    }
}
