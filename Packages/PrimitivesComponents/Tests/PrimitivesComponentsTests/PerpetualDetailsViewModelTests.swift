// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Formatters
import Primitives
import PrimitivesTestKit
@testable import PrimitivesComponents

struct PerpetualDetailsViewModelTests {

    @Test
    func leverageText() {
        #expect(PerpetualDetailsViewModel.mock(.mock(leverage: 5)).leverageText == "5x")
    }

    @Test
    func slippageText() {
        let model = PerpetualDetailsViewModel.mock(.mock(slippage: 2.0))
        #expect(model.slippageText == "2.00%")
    }

    @Test
    func entryPriceText() {
        #expect(PerpetualDetailsViewModel.mock(.mock(entryPrice: 48000.0)).entryPriceText == "$48,000.00")
        #expect(PerpetualDetailsViewModel.mock(.mock(entryPrice: nil)).entryPriceText == nil)
    }

    @Test
    func marginText() {
        let model = PerpetualDetailsViewModel.mock(.mock(marginAmount: 1000.0))
        #expect(model.marginText == "$1,000.00")
    }

    @Test
    func listItemModelWithPnL() {
        let model = PerpetualDetailsViewModel.mock(.mock(pnl: 500, marginAmount: 1000))

        #expect(model.listItemModel.title == "Details")
        #expect(model.listItemModel.subtitle == "+$500.00 (+50.00%)")
    }
}

extension PerpetualDetailsViewModel {
    static func mock(_ data: PerpetualConfirmData) -> PerpetualDetailsViewModel {
        PerpetualDetailsViewModel(data: data)
    }
}
