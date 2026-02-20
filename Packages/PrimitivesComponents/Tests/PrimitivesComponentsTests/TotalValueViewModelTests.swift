// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Style
import PrimitivesComponentsTestKit
@testable import PrimitivesComponents

struct TotalValueViewModelTests {

    @Test
    func title() {
        #expect(TotalValueViewModel.mock(value: 1000).title == "$1,000.00")
        #expect(TotalValueViewModel.mock(value: 0).title == "$0.00")
    }

    @Test
    func pnlAmountText() {
        #expect(TotalValueViewModel.mock(pnlAmount: 50).pnlAmountText == "+$50.00")
        #expect(TotalValueViewModel.mock(pnlAmount: -50).pnlAmountText == "-$50.00")
        #expect(TotalValueViewModel.mock(pnlAmount: 0).pnlAmountText == nil)
    }

    @Test
    func pnlPercentageText() {
        #expect(TotalValueViewModel.mock(pnlPercentage: 5).pnlPercentageText == "5.00%")
        #expect(TotalValueViewModel.mock(pnlPercentage: -5).pnlPercentageText == "5.00%")
        #expect(TotalValueViewModel.mock(pnlAmount: 0).pnlPercentageText == nil)
    }

    @Test
    func pnlColor() {
        #expect(TotalValueViewModel.mock(pnlAmount: 50).pnlColor == Colors.green)
        #expect(TotalValueViewModel.mock(pnlAmount: -50).pnlColor == Colors.red)
        #expect(TotalValueViewModel.mock(pnlAmount: 0).pnlColor == Colors.gray)
    }
}
