// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct SetPriceAlertInput: Identifiable, Sendable {
    public var id: String { asset.id.identifier }
    public let asset: Asset
    public let price: Double?

    public init(asset: Asset, price: Double?) {
        self.asset = asset
        self.price = price
    }
}
