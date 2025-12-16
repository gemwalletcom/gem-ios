// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

struct ChainAssetRecordInfo: FetchableRecord, Decodable {
    var asset: AssetRecord
    var price: PriceRecord?
    var account: AccountRecord
    var balance: BalanceRecord?
    var priceAlerts: [PriceAlertRecord]?
    var nativeAssetInfo: NativeAssetInfo

    struct NativeAssetInfo: FetchableRecord, Decodable {
        var nativeAsset: AssetRecord
        var nativeBalance: BalanceRecord?
    }
}

extension ChainAssetRecordInfo {
    var chainAssetData: ChainAssetData {
        ChainAssetData(
            assetData: assetRecordInfo.assetData,
            nativeAssetData: nativeRecordInfo.assetData
        )
    }

    private var assetRecordInfo: AssetRecordInfo {
        AssetRecordInfo(
            asset: asset,
            price: price,
            account: account,
            balance: balance,
            priceAlerts: priceAlerts
        )
    }

    private var nativeRecordInfo: AssetRecordInfo {
        AssetRecordInfo(
            asset: nativeAssetInfo.nativeAsset,
            price: nil,
            account: account,
            balance: nativeAssetInfo.nativeBalance,
            priceAlerts: nil
        )
    }
}
