// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Testing
import Primitives
import PrimitivesTestKit

@testable import Transfer

struct AmountPerpetualViewModelTests {

    @Test
    func title() {
        let openLong = AmountPerpetualViewModel(asset: .mock(), data: .mock(positionAction: .open(.mock(direction: .long))))
        let openShort = AmountPerpetualViewModel(asset: .mock(), data: .mock(positionAction: .open(.mock(direction: .short))))

        #expect(openLong.title == "Long")
        #expect(openShort.title == "Short")
    }

    @Test
    func increaseReduceTitle() {
        let increase = AmountPerpetualViewModel(asset: .mock(), data: .mock(positionAction: .increase(.mock(direction: .long))))
        let reduce = AmountPerpetualViewModel(asset: .mock(), data: .mock(positionAction: .reduce(.mock(), available: 1000, positionDirection: .long)))

        #expect(increase.title.contains("Long"))
        #expect(reduce.title.contains("Long"))
    }

    @Test
    func leverageSelection() {
        let open = AmountPerpetualViewModel(asset: .mock(), data: .mock(positionAction: .open(.mock(leverage: 10))))
        let increase = AmountPerpetualViewModel(asset: .mock(), data: .mock(positionAction: .increase(.mock())))

        #expect(open.leverageSelection != nil)
        #expect(open.leverageSelection?.isEnabled == true)
        #expect(increase.leverageSelection == nil)
    }

    @Test
    func isAutocloseEnabled() {
        let open = AmountPerpetualViewModel(asset: .mock(), data: .mock(positionAction: .open(.mock())))
        let increase = AmountPerpetualViewModel(asset: .mock(), data: .mock(positionAction: .increase(.mock())))
        let reduce = AmountPerpetualViewModel(asset: .mock(), data: .mock(positionAction: .reduce(.mock(), available: 1000, positionDirection: .long)))

        #expect(open.isAutocloseEnabled == true)
        #expect(increase.isAutocloseEnabled == false)
        #expect(reduce.isAutocloseEnabled == false)
    }

    @Test
    func availableValue() {
        let assetData = AssetData.mock(balance: .mock(available: 5000))

        let open = AmountPerpetualViewModel(asset: .mock(), data: .mock(positionAction: .open(.mock())))
        let reduce = AmountPerpetualViewModel(asset: .mock(), data: .mock(positionAction: .reduce(.mock(), available: 1000, positionDirection: .long)))

        #expect(open.availableValue(from: assetData) == 5000)
        #expect(reduce.availableValue(from: assetData) == 1000)
    }

    @Test
    func reserveForFee() {
        let model = AmountPerpetualViewModel(asset: .mock(), data: .mock())
        #expect(model.reserveForFee == .zero)
        #expect(model.shouldReserveFee(from: .mock()) == false)
    }

    @Test
    func minimumValue() {
        let model = AmountPerpetualViewModel(asset: .mock(), data: .mock())
        #expect(model.minimumValue > .zero)
    }

    @Test
    func autocloseText() {
        let model = AmountPerpetualViewModel(asset: .mock(), data: .mock())

        #expect(model.autocloseText.subtitle == "-")
        #expect(model.autocloseText.subtitleExtra == nil)

        model.takeProfit = "100"
        #expect(model.autocloseText.subtitle.contains("TP"))

        model.stopLoss = "50"
        #expect(model.autocloseText.subtitleExtra != nil)
    }

    @Test
    func makeAutocloseData() {
        let model = AmountPerpetualViewModel(asset: .mock(), data: .mock(positionAction: .open(.mock(direction: .long))))
        model.takeProfit = "100"
        model.stopLoss = "50"

        let data = model.makeAutocloseData(size: 1000)

        #expect(data.direction == .long)
        #expect(data.takeProfit == "100")
        #expect(data.stopLoss == "50")
        #expect(data.size == 1000)
    }

    @Test
    func makeTransferData() throws {
        let open = try AmountPerpetualViewModel(asset: .mock(), data: .mock(positionAction: .open(.mock()))).makeTransferData(value: 100)
        let increase = try AmountPerpetualViewModel(asset: .mock(), data: .mock(positionAction: .increase(.mock()))).makeTransferData(value: 200)
        let reduce = try AmountPerpetualViewModel(asset: .mock(), data: .mock(positionAction: .reduce(.mock(), available: 1000, positionDirection: .long))).makeTransferData(value: 300)

        #expect(open.type.transactionType == .perpetualOpenPosition)
        #expect(increase.type.transactionType == .perpetualOpenPosition)
        #expect(reduce.type.transactionType == .perpetualClosePosition)
        #expect(open.value == 100)
        #expect(increase.value == 200)
        #expect(reduce.value == 300)
    }
}
