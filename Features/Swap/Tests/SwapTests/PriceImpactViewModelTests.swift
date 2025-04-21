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
        let value = viewModel.value

        #expect(value == nil)
    }

    @Test
    func testPriceImpactValue_Positive() {
        let viewModel = PriceImpactViewModel.mock(fromValue: "1000000000", toValue: "1005000000")
        let value = viewModel.value

        #expect(value == PriceImpactValue(type: .positive, value: "+0.50%"))
    }

    @Test
    func testPriceImpactValue_Medium() {
        let viewModel = PriceImpactViewModel.mock(fromValue: "1000000000", toValue: "950000000")
        let value = viewModel.value

        #expect(value == PriceImpactValue(type: .medium, value: "-5.00%"))
    }

    @Test
    func testPriceImpactValue_High() {
        let viewModel = PriceImpactViewModel.mock(fromValue: "1000000000", toValue: "700000000")
        let value = viewModel.value

        #expect(value == PriceImpactValue(type: .high, value: "-30.00%"))
    }

    @Test
    func testHighImpactConfirmationTextAboveThreshold() {
        let vm = PriceImpactViewModel.mock(fromValue: "1000000000", toValue: "300000000")
        #expect(vm.highImpactConfirmationText != nil)
    }

    @Test
    func testHighImpactConfirmationTextBelowThreshold() {
        let vm = PriceImpactViewModel.mock(fromValue: "1000000000", toValue: "850000000")
        #expect(vm.highImpactConfirmationText == nil)
    }
}

extension PriceImpactViewModel {
    static func mock(fromValue: String, toValue: String) -> PriceImpactViewModel {
        let fromAssetData = AssetData.mock(
            price: .mock()
        )
        
        let toAssetData = AssetData.mock(
            price: .mock()
        )
        
        return PriceImpactViewModel(
            fromAssetData: fromAssetData,
            fromValue: fromValue,
            toAssetData: toAssetData,
            toValue: toValue
        )
    }
}
