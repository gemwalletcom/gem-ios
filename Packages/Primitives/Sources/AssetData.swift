// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct AssetAddress: Codable, Equatable, Hashable, Sendable {
    public let asset: Asset
    public let address: String

    public init(asset: Asset, address: String) {
        self.asset = asset
        self.address = address
    }
}

public struct AssetData: Codable, Equatable, Hashable, Sendable {
    public let asset: Asset
    public let balance: Balance
    public let account: Account
    public let price: Price?
    public let price_alerts: [PriceAlert]
    public let metadata: AssetMetaData

    public init(asset: Asset, balance: Balance, account: Account, price: Price?, price_alerts: [PriceAlert], metadata: AssetMetaData) {
        self.asset = asset
        self.balance = balance
        self.account = account
        self.price = price
        self.price_alerts = price_alerts
        self.metadata = metadata
    }
}
