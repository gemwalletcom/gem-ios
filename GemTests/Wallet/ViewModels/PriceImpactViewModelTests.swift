// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import XCTest
import PrimitivesTestKit
import Primitives
@testable import Gem

final class PriceImpactViewModelTests: XCTestCase {
    
    func testPriceImpactValue_None_InvalidInput() {
        let viewModel = viewModel(fromValue: "wrong", toValue: "wrong")
        let result = viewModel.type()
        XCTAssertEqual(result, .none)
    }
    
    func testPriceImpactValue_Low() {
        let viewModel = viewModel(fromValue: "10", toValue: "9.9")
        let type = viewModel.type()
        XCTAssertEqual(type, .low("-1.00%"))
    }
    
    func testPriceImpactValue_Positive() {
        let viewModel = viewModel(fromValue: "10", toValue: "10.05")
        let type = viewModel.type()
        XCTAssertEqual(type, .positive("+0.50%"))
    }
    
    func testPriceImpactValue_Medium() {
        let viewModel = viewModel(fromValue: "10", toValue: "9.5")
        let type = viewModel.type()
        XCTAssertEqual(type, .medium("-5.00%"))
    }
    
    func testPriceImpactValue_High() {
        let viewModel = viewModel(fromValue: "10", toValue: "7.0")
        let type = viewModel.type()
        XCTAssertEqual(type, .high("-30.00%"))
    }
    
    private func viewModel(fromValue: String, toValue: String) -> PriceImpactViewModel {
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
