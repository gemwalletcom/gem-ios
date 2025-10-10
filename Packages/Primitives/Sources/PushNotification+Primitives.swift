// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum PushNotification: Equatable, Sendable {
    case transaction(walletIndex: Int, AssetId, transactionId: String)
    case asset(AssetId)
    case priceAlert(AssetId)
    case buyAsset(AssetId)
    case swapAsset(AssetId, AssetId?)
    case test
    case support
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
            self = .transaction(walletIndex: transaction.walletIndex.asInt, assetId, transactionId: transaction.transactionId)
        case .asset:
            let asset = try decoder.decode(PushNotificationAsset.self, from: data)
            self = .asset(try AssetId(id: asset.assetId))
        case .priceAlert:
            let asset = try decoder.decode(PushNotificationAsset.self, from: data)
            self = .priceAlert(try AssetId(id: asset.assetId))
        case .buyAsset:
            let asset = try decoder.decode(PushNotificationAsset.self, from: data)
            self = .buyAsset(try AssetId(id: asset.assetId))
        case .swapAsset:
            let swapAsset = try decoder.decode(PushNotificationSwapAsset.self, from: data)
            let fromAssetId = try AssetId(id: swapAsset.fromAssetId)
            let toAssetId = try AssetId(id: swapAsset.toAssetId)
            self = .swapAsset(fromAssetId, toAssetId)
        case .support:
            self = .support
        case .test:
            self = .test
        }
    }
}
