import XCTest
@testable import Gem
import Primitives

final class PriceViewModelTests: XCTestCase {

    func testIsPriceAvailable() {
        XCTAssertFalse(PriceViewModel(price: nil).isPriceAvailable)
        XCTAssertFalse(PriceViewModel(price: Price(price: 0, priceChangePercentage24h: 0)).isPriceAvailable)
        XCTAssertTrue(PriceViewModel(price: Price(price: 10, priceChangePercentage24h: 5)).isPriceAvailable)
    }
    
    func testPriceAmountText() {
        XCTAssertEqual(PriceViewModel(price: Price(price: 10, priceChangePercentage24h: 5)).priceAmountText, "$10.00")
        XCTAssertEqual(PriceViewModel(price: Price(price: -10, priceChangePercentage24h: -5)).priceAmountText, "-$10.00")
    }
    
    func testPriceAmountPositiveText() {
        XCTAssertEqual(PriceViewModel(price: Price(price: 10, priceChangePercentage24h: 5)).priceAmountText, "$10.00")
        XCTAssertEqual(PriceViewModel(price: Price(price: -10, priceChangePercentage24h: -5)).priceAmountText, "-$10.00")
    }
    
    func testPriceAmountChangeText() {
        XCTAssertEqual(PriceViewModel(price: Price(price: 10, priceChangePercentage24h: 5)).priceChangeText, "+5.00%")
        XCTAssertEqual(PriceViewModel(price: Price(price: -10, priceChangePercentage24h: -5)).priceChangeText, "-5.00%")
    }
}
