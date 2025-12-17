// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct SetPriceAlertInput: Identifiable, Sendable {
    public var id: String { assetId.identifier }
    public let assetId: AssetId
    public let price: Double

    public init(assetId: AssetId, price: Double) {
        self.assetId = assetId
        self.price = price
    }
}
