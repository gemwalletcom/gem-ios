// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

public struct AutocloseOpenData: Sendable {
    public let direction: PerpetualDirection
    public let marketPrice: Double
    public let leverage: UInt8
    public let size: Double
    public let assetDecimals: Int32
    public let takeProfit: String?
    public let stopLoss: String?

    public init(
        direction: PerpetualDirection,
        marketPrice: Double,
        leverage: UInt8,
        size: Double,
        assetDecimals: Int32,
        takeProfit: String?,
        stopLoss: String?
    ) {
        self.direction = direction
        self.marketPrice = marketPrice
        self.leverage = leverage
        self.size = size
        self.assetDecimals = assetDecimals
        self.takeProfit = takeProfit
        self.stopLoss = stopLoss
    }
}
