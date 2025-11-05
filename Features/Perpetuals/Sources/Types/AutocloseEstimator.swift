// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct AutocloseEstimator {
    public let entryPrice: Double
    public let positionSize: Double
    public let direction: PerpetualDirection
    public let leverage: UInt8

    public init(entryPrice: Double, positionSize: Double, direction: PerpetualDirection, leverage: UInt8) {
        self.entryPrice = entryPrice
        self.positionSize = positionSize
        self.direction = direction
        self.leverage = leverage
    }

    public func calculateTargetPriceFromROE(roePercent: Int, type: TpslType) -> Double {
        let priceChangePercent = Double(roePercent) / Double(leverage) / 100.0

        return switch (direction, type) {
        case (.long, .takeProfit), (.short, .stopLoss): entryPrice * (1 + priceChangePercent)
        case (.long, .stopLoss), (.short, .takeProfit): entryPrice * (1 - priceChangePercent)
        }
    }

    public func calculatePnL(price: Double) -> Double {
        let side: Double = direction == .long ? 1 : -1
        return side * (price - entryPrice) * abs(positionSize)
    }

    public func calculatePriceChangePercent(price: Double) -> Double {
        let rawChange = ((price - entryPrice) / entryPrice) * 100
        return direction == .short ? -rawChange : rawChange
    }

    public func calculateROE(price: Double) -> Double {
        let priceChangePercent = calculatePriceChangePercent(price: price)
        return priceChangePercent * Double(leverage)
    }
}
