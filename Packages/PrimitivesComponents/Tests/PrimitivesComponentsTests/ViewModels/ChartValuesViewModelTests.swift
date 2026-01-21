// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Foundation
import Primitives
import PrimitivesTestKit
import PrimitivesComponentsTestKit
@testable import PrimitivesComponents

struct ChartValuesViewModelTests {

    @Test
    func chartValuesViewModel() {
        let model = ChartValuesViewModel.mock(price: .mock(price: 150), values: .mock(values: [100, 200]))

        #expect(model.lowerBoundValueText == "$100.00")
        #expect(model.upperBoundValueText == "$200.00")
        #expect(model.chartPriceViewModel?.price == 150)
        #expect(model.priceViewModel(for: ChartDateValue(date: Date(), value: 150)).priceChangePercentage == 50)

        #expect(ChartValuesViewModel.mock(price: nil).chartPriceViewModel == nil)
        #expect(ChartValuesViewModel.mock(period: .week, price: .mock(price: 150), values: .mock(values: [100, 200])).chartPriceViewModel?.priceChangePercentage == 50)
    }
}
