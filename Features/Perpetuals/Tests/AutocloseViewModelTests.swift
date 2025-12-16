// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import PerpetualsTestKit

@testable import Perpetuals

struct AutocloseViewModelTests {

    @Test
    func title() {
        #expect(AutocloseViewModel.mock(type: .takeProfit).title == "Take profit")
        #expect(AutocloseViewModel.mock(type: .stopLoss).title == "Stop loss")
    }

    @Test
    func profitTitleTakeProfit() {
        #expect(AutocloseViewModel.mock(type: .takeProfit, price: nil).profitTitle == "Expected profit")
        #expect(AutocloseViewModel.mock(type: .takeProfit, price: 110.0).profitTitle == "Expected profit")
        #expect(AutocloseViewModel.mock(type: .takeProfit, price: 90.0).profitTitle == "Expected loss")
    }

    @Test
    func profitTitleStopLoss() {
        #expect(AutocloseViewModel.mock(type: .stopLoss, price: nil).profitTitle == "Expected loss")
        #expect(AutocloseViewModel.mock(type: .stopLoss, price: 90.0).profitTitle == "Expected loss")
        #expect(AutocloseViewModel.mock(type: .stopLoss, price: 110.0).profitTitle == "Expected profit")
    }

    @Test
    func expectedPnLNil() {
        #expect(AutocloseViewModel.mock(price: nil).expectedPnL == "-")
    }

    @Test
    func expectedPnLProfit() {
        #expect(AutocloseViewModel.mock(price: 110.0).expectedPnL == "+$100.00 (+50.00%)")
        #expect(AutocloseViewModel.mock(price: 110.0, positionSize: 0).expectedPnL == "+50.00%")
    }

    @Test
    func expectedPnLLoss() {
        #expect(AutocloseViewModel.mock(price: 90.0).expectedPnL == "-$100.00 (-50.00%)")
        #expect(AutocloseViewModel.mock(price: 90.0, positionSize: 0).expectedPnL == "-50.00%")
    }

    @Test
    func percentages() {
        #expect(AutocloseViewModel.mock(leverage: 1).percents == [5, 10, 15])
        #expect(AutocloseViewModel.mock(leverage: 3).percents == [5, 10, 15])
        #expect(AutocloseViewModel.mock(leverage: 4).percents == [10, 15, 25])
        #expect(AutocloseViewModel.mock(leverage: 10).percents == [10, 15, 25])
        #expect(AutocloseViewModel.mock(leverage: 11).percents == [25, 50, 100])
        #expect(AutocloseViewModel.mock(leverage: 50).percents == [25, 50, 100])
    }
}
