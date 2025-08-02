// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB

struct PerpetualAssetBalance: FetchableRecord, Codable {
    var asset: AssetRecord
    var balance: BalanceRecord
}

extension PerpetualAssetBalance {
    var totalFiatAmount: Double {
        balance.availableAmount + balance.reservedAmount
    }
}
