// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum PushNotification: Equatable {
    case transaction(walletIndex: Int, AssetId)
    case priceAlert(AssetId)
    case buyAsset(AssetId)
    case swapAsset(AssetId, AssetId)
    case test
    case unknown

    public init(from userInfo: [AnyHashable: Any]) throws {
        guard
            let typeString = userInfo["type"] as? String,
            let type = PushNotificationTypes(rawValue: typeString),
            let dataDict = userInfo["data"] as? [AnyHashable: Any] else {
            self = .unknown
            return
        }

        let data = try JSONSerialization.data(withJSONObject: dataDict, options: [])
        let decoder = JSONDecoder()
        switch type {
        case .transaction:
            let transaction = try decoder.decode(PushNotificationTransaction.self, from: data)
            let assetId = try AssetId(id: transaction.assetId)
            self = .transaction(walletIndex: transaction.walletIndex.asInt, assetId)
        case .priceAlert:
            let priceAlert = try decoder.decode(PushNotificationPriceAlert.self, from: data)
            let assetId = try AssetId(id: priceAlert.assetId)
            self = .priceAlert(assetId) 
        case .buyAsset:
            let buyAsset = try decoder.decode(PushNotificationBuyAsset.self, from: data)
            let assetId = try AssetId(id: buyAsset.assetId)
            self = .buyAsset(assetId)
        case .swapAsset:
            let swapAsset = try decoder.decode(PushNotificationSwapAsset.self, from: data)
            let fromAssetId = try AssetId(id: swapAsset.fromAssetId)
            let toAssetId = try AssetId(id: swapAsset.toAssetId)
            self = .swapAsset(fromAssetId, toAssetId)
        case .test:
            self = .test
        }
    }
}
