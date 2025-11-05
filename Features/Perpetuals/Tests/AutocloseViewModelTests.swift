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
        let model = AutocloseViewModel.mock(price: 110.0)
        #expect(model.expectedPnL == "+$100.00 (+50.00%)")
    }

    @Test
    func expectedPnLLoss() {
        let model = AutocloseViewModel.mock(price: 90.0)
        #expect(model.expectedPnL == "-$100.00 (-50.00%)")
    }
}
