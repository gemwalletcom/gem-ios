// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum PushNotification: Equatable {
    case transaction(PushNotificationTransaction)
    case priceAlert(PriceAlert)
    case buyAsset(AssetId)
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
            self = .transaction(transaction)
        case .priceAlert:
            let priceAlert = try decoder.decode(PriceAlert.self, from: data)
            self = .priceAlert(priceAlert)
        case .buyAsset:
            let buyAsset = try decoder.decode(PushNotificationBuyAsset.self, from: data)
            let assetId = try AssetId(id: buyAsset.assetId)
            self = .buyAsset(assetId)
        case .test:
            self = .test
        }
    }
}
