// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB

struct PriceRecordInfo: FetchableRecord, Codable {
    var asset: AssetRecord
    var price: PriceRecord?
    var details: AssetDetailsRecord?
    var priceAlert: PriceAlertRecord?
}
