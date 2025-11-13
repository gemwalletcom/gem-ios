// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
@testable import Perpetuals

struct AutocloseEstimatorTests {

    @Test
    func calculatePnLLong() {
        let estimator = AutocloseEstimator(entryPrice: 100.0, positionSize: 10.0, direction: .long, leverage: 5)

        #expect(estimator.calculatePnL(price: 110.0) == 100.0)
        #expect(estimator.calculatePnL(price: 90.0) == -100.0)
    }

    @Test
    func calculatePnLShort() {
        let estimator = AutocloseEstimator(entryPrice: 100.0, positionSize: -10.0, direction: .short, leverage: 5)

        #expect(estimator.calculatePnL(price: 90.0) == 100.0)
        #expect(estimator.calculatePnL(price: 110.0) == -100.0)
    }

    @Test
    func calculateROELong() {
        let estimator = AutocloseEstimator(entryPrice: 100.0, positionSize: 10.0, direction: .long, leverage: 5)

        #expect(estimator.calculateROE(price: 110.0) == 50.0)
        #expect(estimator.calculateROE(price: 90.0) == -50.0)
    }

    @Test
    func calculateROEShort() {
        let estimator = AutocloseEstimator(entryPrice: 100.0, positionSize: -10.0, direction: .short, leverage: 5)

        #expect(estimator.calculateROE(price: 90.0) == 50.0)
        #expect(estimator.calculateROE(price: 110.0) == -50.0)
    }

    @Test
    func calculateTargetPriceFromROELong() {
        let estimator = AutocloseEstimator(entryPrice: 100.0, positionSize: 10.0, direction: .long, leverage: 5)

        #expect(abs(estimator.calculateTargetPriceFromROE(roePercent: 50, type: .takeProfit) - 110.0) < 0.0001)
        #expect(abs(estimator.calculateTargetPriceFromROE(roePercent: 50, type: .stopLoss) - 90.0) < 0.0001)
    }

    @Test
    func calculateTargetPriceFromROEShort() {
        let estimator = AutocloseEstimator(entryPrice: 100.0, positionSize: -10.0, direction: .short, leverage: 5)

        #expect(abs(estimator.calculateTargetPriceFromROE(roePercent: 50, type: .takeProfit) - 90.0) < 0.0001)
        #expect(abs(estimator.calculateTargetPriceFromROE(roePercent: 50, type: .stopLoss) - 110.0) < 0.0001)
    }
}
