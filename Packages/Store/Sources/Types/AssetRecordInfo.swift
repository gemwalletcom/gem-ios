// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB

struct AssetRecordInfo: FetchableRecord, Codable {
    var asset: AssetRecord
    var price: PriceRecord?
    var account: AccountRecord
    var balance: AssetBalanceRecord?
    var details: AssetDetailsRecord?
}

struct AssetRecordInfoMinimal: FetchableRecord, Codable {
    var price: PriceRecord?
    var balance: AssetBalanceRecord
}
