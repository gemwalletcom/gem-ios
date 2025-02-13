// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import PrimitivesTestKit
import Primitives

@testable import Swap

struct PriceImpactViewModelTests {

    @Test
    func testPriceImpactValue_Low() {
        let viewModel = PriceImpactViewModel.mock(fromValue: "1000000000", toValue: "990000000")
        let value = viewModel.value()
        let expectedValue = PriceImpactValue(type: .low, value: "-1.00%")

        #expect(value == expectedValue)
    }

    @Test
    func testPriceImpactValue_Positive() {
        let viewModel = PriceImpactViewModel.mock(fromValue: "1000000000", toValue: "1005000000")
        let value = viewModel.value()
        let expectedValue = PriceImpactValue(type: .positive, value: "+0.50%")

        #expect(value == expectedValue)
    }

    @Test
    func testPriceImpactValue_Medium() {
        let viewModel = PriceImpactViewModel.mock(fromValue: "1000000000", toValue: "950000000")
        let value = viewModel.value()
        let expectedValue = PriceImpactValue(type: .medium, value: "-5.00%")

        #expect(value == expectedValue)
    }

    @Test
    func testPriceImpactValue_High() {
        let viewModel = PriceImpactViewModel.mock(fromValue: "1000000000", toValue: "700000000")
        let value = viewModel.value()
        let expectedValue = PriceImpactValue(type: .high, value: "-30.00%")

        #expect(value == expectedValue)
    }
}

extension PriceImpactViewModel {
    static func mock(fromValue: String, toValue: String) -> PriceImpactViewModel {
        let fromAssetData = AssetData.mock(
            price: Price(price: 5, priceChangePercentage24h: 1)
        )
        
        let toAssetData = AssetData.mock(
            price: Price(price: 5, priceChangePercentage24h: 1)
        )
        
        return PriceImpactViewModel(
            fromAssetData: fromAssetData,
            fromValue: fromValue,
            toAssetData: toAssetData,
            toValue: toValue
        )
    }
}
