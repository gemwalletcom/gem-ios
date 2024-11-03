// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB

struct AssetRecordInfo: FetchableRecord, Codable {
    var asset: AssetRecord
    var price: PriceRecord?
    var account: AccountRecord
    var balance: AssetBalanceRecord?
    var details: AssetDetailsRecord?
    var priceAlert: PriceAlertRecord?
    //var priceAlerts: [PriceAlertRecord]?
}

struct AssetRecordInfoMinimal: FetchableRecord, Codable {
    var asset: AssetRecord
    var price: PriceRecord?
    var balance: AssetBalanceRecord
}

extension AssetRecordInfoMinimal {
    var totalFiatAmount: Double {
        return balance.totalAmount * (price?.price ?? 0)
    }
}
