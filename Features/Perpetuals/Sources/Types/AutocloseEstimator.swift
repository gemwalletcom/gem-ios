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

    func calculatePnL(triggerPrice: Double) -> Double {
        let side: Double = direction == .long ? 1 : -1
        return side * (triggerPrice - entryPrice) * abs(positionSize)
    }

    func calculatePriceChangePercent(triggerPrice: Double) -> Double {
        ((triggerPrice - entryPrice) / entryPrice) * 100
    }

    func calculateROE(triggerPrice: Double) -> Double {
        let priceChangePercent = calculatePriceChangePercent(triggerPrice: triggerPrice)
        return priceChangePercent * Double(leverage)
    }

    func calculateAbsolutePnL(triggerPrice: Double) -> Double {
        abs(calculatePnL(triggerPrice: triggerPrice))
    }

    func calculateAbsoluteROE(triggerPrice: Double) -> Double {
        abs(calculateROE(triggerPrice: triggerPrice))
    }
}
