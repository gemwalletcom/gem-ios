// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import PrimitivesTestKit
import PerpetualsTestKit
import Formatters
@testable import Perpetuals

struct CandleTooltipViewModelTests {

    @Test
    func tooltipContent() {
        let model = CandleTooltipViewModel.mock(candle: .mock(open: 67_715, high: 68_181, low: 67_714, close: 68_087, volume: 500))

        #expect(model.openTitle.text == "Open")
        #expect(model.openValue.text == "67,715.00")

        #expect(model.highTitle.text == "High")
        #expect(model.highValue.text == "68,181.00")

        #expect(model.lowTitle.text == "Low")
        #expect(model.lowValue.text == "67,714.00")

        #expect(model.closeTitle.text == "Close")
        #expect(model.closeValue.text == "68,087.00")

        #expect(model.changeTitle.text == "Change")
        #expect(model.changeValue.text == "+0.55%")

        #expect(model.volumeTitle.text == "Volume")
        #expect(model.volumeValue.text == "$34.04M")
    }

    @Test
    func changeSign() {
        #expect(CandleTooltipViewModel.mock(candle: .mock(open: 100, close: 105)).changeValue.text == "+5.00%")
        #expect(CandleTooltipViewModel.mock(candle: .mock(open: 100, close: 95)).changeValue.text == "-5.00%")
        #expect(CandleTooltipViewModel.mock(candle: .mock(open: 100, close: 100)).changeValue.text == "+0.00%")
    }
}
