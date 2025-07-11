// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import PrimitivesTestKit
import Primitives

@testable import Swap

struct PriceImpactViewModelTests {

    @Test
    func testPriceImpactValue_Low() {
        let model = PriceImpactViewModel.mock(fromValue: "1000000000", toValue: "990000000")
        let value = model.value

        #expect(value == PriceImpactValue(type: Swap.PriceImpactType.low, value: "-1.00%"))
    }

    @Test
    func testPriceImpactValue_Positive() {
        let model = PriceImpactViewModel.mock(fromValue: "1000000000", toValue: "1005000000")
        let value = model.value

        #expect(value == PriceImpactValue(type: .positive, value: "+0.50%"))
    }

    @Test
    func testPriceImpactValue_Medium() {
        let model = PriceImpactViewModel.mock(fromValue: "1000000000", toValue: "950000000")
        let value = model.value

        #expect(value == PriceImpactValue(type: .medium, value: "-5.00%"))
    }

    @Test
    func testPriceImpactValue_High() {
        let model = PriceImpactViewModel.mock(fromValue: "1000000000", toValue: "700000000")
        let value = model.value

        #expect(value == PriceImpactValue(type: .high, value: "-30.00%"))
    }
    
    @Test
    func testShowPriceImpactWarning() {
        #expect(PriceImpactViewModel.mock(fromValue: "100", toValue: "109").showPriceImpactWarning == false)
        #expect(PriceImpactViewModel.mock(fromValue: "100", toValue: "111").showPriceImpactWarning == true)
        #expect(PriceImpactViewModel.mock(fromValue: "100", toValue: "120").showPriceImpactWarning == true)
    }
    
    @Test
    func testPriceImpactText() {
        #expect(PriceImpactViewModel.mock(fromValue: "100", toValue: "109").priceImpactText == "9.00%")
        #expect(PriceImpactViewModel.mock(fromValue: "100", toValue: "111").priceImpactText == "11.00%")
        #expect(PriceImpactViewModel.mock(fromValue: "100", toValue: "120").priceImpactText == "20.00%")
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
