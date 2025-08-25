// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct AssetBalancePrice: Sendable, Equatable {
    public let assetId: AssetId

    public let balance: Balance
    public let price: AssetPrice?

    public init(
        assetId: AssetId,
        balance: Balance,
        price: AssetPrice?
    ) {
        self.balance = balance
        self.price = price
        self.assetId = assetId
    }
}
