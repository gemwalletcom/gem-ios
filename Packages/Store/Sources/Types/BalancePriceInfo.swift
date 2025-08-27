// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

struct BalancePriceInfo: FetchableRecord, Codable {
    var asset: AssetRecord
    var balance: BalanceRecord?
    var price: PriceRecord?
}

extension BalancePriceInfo {
    func mapToAssetBalancePrice() -> AssetBalancePrice {
        AssetBalancePrice(
            balance: balance?.mapToBalance() ?? .zero,
            price: price?.mapToAssetPrice()
        )
    }
}
