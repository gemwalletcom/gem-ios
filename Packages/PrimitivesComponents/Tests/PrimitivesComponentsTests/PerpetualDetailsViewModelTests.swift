// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Formatters
import Primitives
import PrimitivesTestKit
@testable import PrimitivesComponents

struct PerpetualDetailsViewModelTests {

    @Test
    func leverageText() {
        #expect(PerpetualDetailsViewModel.mock(.open(.mock(leverage: 5))).leverageText == "5x")
    }

    @Test
    func slippageText() {
        #expect(PerpetualDetailsViewModel.mock(.open(.mock(slippage: 2.0))).slippageText == "2.00%")
    }

    @Test
    func entryPriceText() {
        #expect(PerpetualDetailsViewModel.mock(.open(.mock(entryPrice: 48000.0))).entryPriceText == "$48,000.00")
        #expect(PerpetualDetailsViewModel.mock(.open(.mock(entryPrice: nil))).entryPriceText == nil)
    }

    @Test
    func marginText() {
        #expect(PerpetualDetailsViewModel.mock(.open(.mock(marginAmount: 1000.0))).marginText == "$1,000.00")
    }

    @Test
    func listItemModelSubtitle() {
        let closeModel = PerpetualDetailsViewModel.mock(.close(.mock(pnl: 500, marginAmount: 1000)))
        #expect(closeModel.listItemModel.title == "Details")
        #expect(closeModel.listItemModel.subtitle == "+$500.00 (+50.00%)")

        #expect(PerpetualDetailsViewModel.mock(.open(.mock())).listItemModel.subtitle == "Long 3x")
        
        #expect(PerpetualDetailsViewModel.mock(.increase(.mock())).listItemModel.subtitle == "Increase Long")
        #expect(PerpetualDetailsViewModel.mock(.increase(.mock(direction: .short))).listItemModel.subtitle == "Increase Short")
        #expect(PerpetualDetailsViewModel.mock(.reduce(.mock())).listItemModel.subtitle == "Reduce Long")
        #expect(PerpetualDetailsViewModel.mock(.reduce(.mock(), positionDirection: .short)).listItemModel.subtitle == "Reduce Short")
    }
}

extension PerpetualDetailsViewModel {
    static func mock(_ perpetualType: PerpetualType) -> PerpetualDetailsViewModel {
        PerpetualDetailsViewModel(perpetualType: perpetualType)
    }
}

extension PerpetualType {
    static func reduce(_ data: PerpetualConfirmData, positionDirection: PerpetualDirection = .long) -> PerpetualType {
        .reduce(PerpetualReduceData(data: data, positionDirection: positionDirection))
    }
}
