// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct AutocloseEstimator {
    let entryPrice: Double
    let positionSize: Double
    let direction: PerpetualDirection
    let leverage: UInt8

    func calculateTargetPriceFromROE(roePercent: Int, type: TpslType) -> Double {
        let priceChangePercent = Double(roePercent) / Double(leverage) / 100.0

        return switch (direction, type) {
        case (.long, .takeProfit), (.short, .stopLoss): entryPrice * (1 + priceChangePercent)
        case (.long, .stopLoss), (.short, .takeProfit): entryPrice * (1 - priceChangePercent)
        }
    }

    func calculatePnL(price: Double) -> Double {
        let side: Double = direction == .long ? 1 : -1
        return side * (price - entryPrice) * abs(positionSize)
    }

    func calculatePriceChangePercent(price: Double) -> Double {
        let rawChange = ((price - entryPrice) / entryPrice) * 100
        return direction == .short ? -rawChange : rawChange
    }

    func calculateROE(price: Double) -> Double {
        let priceChangePercent = calculatePriceChangePercent(price: price)
        return priceChangePercent * Double(leverage)
    }
}
