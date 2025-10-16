// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Formatters
import Primitives
import Style
@testable import Perpetuals

struct PnLViewModelTests {

    @Test
    func textPositivePnL() {
        #expect(PnLViewModel.mock(pnl: 500, marginAmount: 1000).text == "+$500.00 (50.00%)")
    }

    @Test
    func textNegativePnL() {
        #expect(PnLViewModel.mock(pnl: -200, marginAmount: 1000).text == "-$200.00 (-20.00%)")
    }

    @Test
    func textNilPnL() {
        #expect(PnLViewModel.mock(pnl: nil, marginAmount: 1000).text == nil)
    }

    @Test
    func percent() {
        #expect(PnLViewModel.mock(pnl: 100, marginAmount: 1000).percent == 10.0)
        #expect(PnLViewModel.mock(pnl: -50, marginAmount: 1000).percent == -5.0)
        #expect(PnLViewModel.mock(pnl: 0, marginAmount: 1000).percent == 0.0)
    }

    @Test
    func percentZeroMargin() {
        #expect(PnLViewModel.mock(pnl: 100, marginAmount: 0).percent == 0.0)
    }

    @Test
    func percentNilPnL() {
        #expect(PnLViewModel.mock(pnl: nil, marginAmount: 1000).percent == 0.0)
    }

    @Test
    func color() {
        #expect(PnLViewModel.mock(pnl: 500, marginAmount: 1000).color == Colors.green)
        #expect(PnLViewModel.mock(pnl: -200, marginAmount: 1000).color == Colors.red)
        #expect(PnLViewModel.mock(pnl: 0, marginAmount: 1000).color == Colors.gray)
        #expect(PnLViewModel.mock(pnl: nil, marginAmount: 1000).color == .secondary)
    }
}

extension PnLViewModel {
    static func mock(pnl: Double?, marginAmount: Double) -> PnLViewModel {
        PnLViewModel(
            pnl: pnl,
            marginAmount: marginAmount,
            currencyFormatter: CurrencyFormatter(type: .currency, currencyCode: Currency.usd.rawValue),
            percentFormatter: CurrencyFormatter(type: .percent, currencyCode: Currency.usd.rawValue)
        )
    }
}
