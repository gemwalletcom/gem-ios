// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives

@testable import Perpetuals
@testable import PerpetualsTestKit

struct AutocloseModifyBuilderTests {

    @Test
    func canBuildWithValidChanges() {
        let builder = AutocloseModifyBuilder.mock()
        let takeProfit = AutocloseField.mock(price: 110.0, originalPrice: 100.0, isValid: true)
        let stopLoss = AutocloseField.mock(price: nil, originalPrice: nil, isValid: false)

        #expect(builder.canBuild(takeProfit: takeProfit, stopLoss: stopLoss) == true)
    }

    @Test
    func cannotBuildWithoutChanges() {
        let builder = AutocloseModifyBuilder.mock()
        let takeProfit = AutocloseField.mock(price: 100.0, originalPrice: 100.0, isValid: true)
        let stopLoss = AutocloseField.mock(price: 90.0, originalPrice: 90.0, isValid: true)

        #expect(builder.canBuild(takeProfit: takeProfit, stopLoss: stopLoss) == false)
    }

    @Test
    func cannotBuildWithInvalidPrice() {
        let builder = AutocloseModifyBuilder.mock()
        let takeProfit = AutocloseField.mock(price: 110.0, originalPrice: 100.0, isValid: false)
        let stopLoss = AutocloseField.mock(price: nil, originalPrice: nil, isValid: false)

        #expect(builder.canBuild(takeProfit: takeProfit, stopLoss: stopLoss) == false)
    }

    @Test
    func canBuildWithClearedField() {
        let builder = AutocloseModifyBuilder.mock()
        let takeProfit = AutocloseField.mock(price: nil, originalPrice: 100.0, isValid: false)
        let stopLoss = AutocloseField.mock(price: nil, originalPrice: nil, isValid: false)

        #expect(builder.canBuild(takeProfit: takeProfit, stopLoss: stopLoss) == true)
    }

    @Test
    func canBuildWithValidTakeProfit() {
        let builder = AutocloseModifyBuilder.mock()
        let takeProfit = AutocloseField.mock(price: 110.0, originalPrice: nil, isValid: true)
        let stopLoss = AutocloseField.mock(price: nil, isValid: false)

        #expect(builder.canBuild(takeProfit: takeProfit, stopLoss: stopLoss) == true)
    }

    @Test
    func canBuildWithValidStopLoss() {
        let builder = AutocloseModifyBuilder.mock()
        let takeProfit = AutocloseField.mock(price: nil, isValid: false)
        let stopLoss = AutocloseField.mock(price: 90.0, originalPrice: nil, isValid: true)

        #expect(builder.canBuild(takeProfit: takeProfit, stopLoss: stopLoss) == true)
    }

    @Test
    func cannotBuildWithoutChangesOrValidFields() {
        let builder = AutocloseModifyBuilder.mock()
        let takeProfit = AutocloseField.mock(price: nil, originalPrice: nil, isValid: false)
        let stopLoss = AutocloseField.mock(price: nil, originalPrice: nil, isValid: false)

        #expect(builder.canBuild(takeProfit: takeProfit, stopLoss: stopLoss) == false)
    }

    @Test
    func cannotBuildWithInvalidPrices() {
        let builder = AutocloseModifyBuilder.mock()
        let takeProfit = AutocloseField.mock(price: 110.0, isValid: false)
        let stopLoss = AutocloseField.mock(price: 90.0, isValid: false)

        #expect(builder.canBuild(takeProfit: takeProfit, stopLoss: stopLoss) == false)
    }

    @Test
    func buildWithNewTakeProfitOnly() {
        let builder = AutocloseModifyBuilder.mock()
        let takeProfit = AutocloseField.mock(price: 110.0, originalPrice: nil, formattedPrice: "110.0", isValid: true)
        let stopLoss = AutocloseField.mock(price: nil, originalPrice: nil, isValid: false)

        let result = builder.build(assetIndex: 5, takeProfit: takeProfit, stopLoss: stopLoss)

        #expect(result.count == 1)
        if case .tpsl(let order) = result[0] {
            #expect(order.takeProfit == "110.0")
            #expect(order.stopLoss == nil)
        }
    }

    @Test
    func buildWithNewStopLossOnly() {
        let builder = AutocloseModifyBuilder.mock()
        let takeProfit = AutocloseField.mock(price: nil, originalPrice: nil, isValid: false)
        let stopLoss = AutocloseField.mock(price: 90.0, originalPrice: nil, formattedPrice: "90.0", isValid: true)

        let result = builder.build(assetIndex: 5, takeProfit: takeProfit, stopLoss: stopLoss)

        #expect(result.count == 1)
        if case .tpsl(let order) = result[0] {
            #expect(order.takeProfit == nil)
            #expect(order.stopLoss == "90.0")
        }
    }

    @Test
    func buildWithBothOrders() {
        let builder = AutocloseModifyBuilder.mock()
        let takeProfit = AutocloseField.mock(price: 110.0, originalPrice: nil, formattedPrice: "110.0", isValid: true)
        let stopLoss = AutocloseField.mock(price: 90.0, originalPrice: nil, formattedPrice: "90.0", isValid: true)

        let result = builder.build(assetIndex: 5, takeProfit: takeProfit, stopLoss: stopLoss)

        #expect(result.count == 1)
        if case .tpsl(let order) = result[0] {
            #expect(order.takeProfit == "110.0")
            #expect(order.stopLoss == "90.0")
        }
    }

    @Test
    func buildWithCancelOnly() {
        let builder = AutocloseModifyBuilder.mock()
        let takeProfit = AutocloseField.mock(price: nil, originalPrice: 100.0, isValid: false, orderId: 12345)
        let stopLoss = AutocloseField.mock(price: nil, originalPrice: nil, isValid: false)

        let result = builder.build(assetIndex: 5, takeProfit: takeProfit, stopLoss: stopLoss)

        #expect(result.count == 1)
        if case .cancel(let cancels) = result[0] {
            #expect(cancels.count == 1)
            #expect(cancels[0].orderId == 12345)
        }
    }

    @Test
    func buildWithCancelAndSet() {
        let builder = AutocloseModifyBuilder.mock()
        let takeProfit = AutocloseField.mock(
            price: 120.0,
            originalPrice: 100.0,
            formattedPrice: "120.0",
            isValid: true,
            orderId: 12345
        )
        let stopLoss = AutocloseField.mock(price: nil, originalPrice: nil, isValid: false)

        let result = builder.build(assetIndex: 5, takeProfit: takeProfit, stopLoss: stopLoss)

        #expect(result.count == 2)
        if case .cancel(let cancels) = result[0] {
            #expect(cancels.count == 1)
            #expect(cancels[0].orderId == 12345)
        }
        if case .tpsl(let order) = result[1] {
            #expect(order.takeProfit == "120.0")
        }
    }

    @Test
    func buildWithCancelBothAndSetBoth() {
        let builder = AutocloseModifyBuilder.mock()
        let takeProfit = AutocloseField.mock(
            price: 120.0,
            originalPrice: 100.0,
            formattedPrice: "120.0",
            isValid: true,
            orderId: 12345
        )
        let stopLoss = AutocloseField.mock(
            price: 80.0,
            originalPrice: 90.0,
            formattedPrice: "80.0",
            isValid: true,
            orderId: 67890
        )

        let result = builder.build(assetIndex: 5, takeProfit: takeProfit, stopLoss: stopLoss)

        #expect(result.count == 2)
        if case .cancel(let cancels) = result[0] {
            #expect(cancels.count == 2)
        }
        if case .tpsl(let order) = result[1] {
            #expect(order.takeProfit == "120.0")
            #expect(order.stopLoss == "80.0")
        }
    }
}
