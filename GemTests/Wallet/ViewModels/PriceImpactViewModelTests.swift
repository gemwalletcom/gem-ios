// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import XCTest
import PrimitivesTestKit
import Primitives
@testable import Gem

final class PriceImpactViewModelTests: XCTestCase {
    var viewModel: PriceImpactViewModel  = {
        let fromAssetData = AssetData.mock(
            price: Price(price: 5, priceChangePercentage24h: 1)
        )
        
        let toAssetData = AssetData.mock(
            price: Price(price: 5, priceChangePercentage24h: 1)
        )
        
        return PriceImpactViewModel(
            fromAssetData: fromAssetData,
            toAssetData: toAssetData
        )
    }()
    
    func testPriceImpactValue_None_InvalidInput() {
        let result = viewModel.priceImpactValue(fromValue: "wrong", toValue: "wrong")
        XCTAssertEqual(result, .none)
    }
    
    func testPriceImpactValue_Low() {
        let result = viewModel.priceImpactValue(fromValue: "10", toValue: "9.9")
        XCTAssertEqual(result, .low("-1.00%"))
    }
    
    func testPriceImpactValue_Positive() {
        let result = viewModel.priceImpactValue(fromValue: "10", toValue: "10.05")
        XCTAssertEqual(result, .positive("+0.50%"))
    }
    
    func testPriceImpactValue_Medium() {
        let result = viewModel.priceImpactValue(fromValue: "10", toValue: "9.5")
        XCTAssertEqual(result, .medium("-5.00%"))
    }
    
    func testPriceImpactValue_High() {
        let result = viewModel.priceImpactValue(fromValue: "10", toValue: "7.0")
        XCTAssertEqual(result, .high("-30.00%"))
    }
}
