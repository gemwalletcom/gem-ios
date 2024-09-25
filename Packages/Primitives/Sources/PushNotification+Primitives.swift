// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum PushNotification {
    case transaction(PushNotificationTransaction)
    case priceAlert(PriceAlert)
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
            let transactionData = try decoder.decode(PushNotificationTransaction.self, from: data)
            self = .transaction(transactionData)
        case .priceAlert:
            let priceAlertData = try decoder.decode(PriceAlert.self, from: data)
            self = .priceAlert(priceAlertData)
        case .test:
            self = .test
        }
    }
}
