// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB

struct AssetRecordInfo: FetchableRecord, Codable {
    var asset: AssetRecord
    var price: PriceRecord?
    var account: AccountRecord
    var balance: BalanceRecord?
    var priceAlerts: [PriceAlertRecord]?
}

struct AssetRecordInfoMinimal: FetchableRecord, Codable {
    var asset: AssetRecord
    var price: PriceRecord?
    var balance: BalanceRecord
}

extension AssetRecordInfoMinimal {
    var totalFiatAmount: Double {
        balance.totalAmount * (price?.price ?? 0)
    }
}
