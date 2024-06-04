import XCTest
import Primitives
@testable import Gem

final class CurrencySceneViewModelTests: XCTestCase {
    func testCurrencyText() {
        let usdCurrency = CurrencySceneViewModelTests.nativeCurrency(currency: .usd)

        let usdCurrencyTitle = usdCurrency?.title
        let mockUsdCurrencyTitle = "🇺🇸 USD - US Dollar"
        XCTAssertEqual(usdCurrencyTitle, mockUsdCurrencyTitle)

        let uahCurrency = CurrencySceneViewModelTests.nativeCurrency(identifier: "UAH")
        let uahCurrencyTitle = uahCurrency?.title

        let mockUAHCurrencyTitle = "🇺🇦 UAH - Ukrainian Hryvnia"
        XCTAssertEqual(uahCurrencyTitle, mockUAHCurrencyTitle)
    }

    func testCurrencyTextWithXDREmojiFlag() {
        let xdrCurrency = CurrencySceneViewModelTests.nativeCurrency(identifier: "XDR")
        let xdrCurrencyTitle = xdrCurrency?.title

        let mockXdrCurrencyTitle = "🏳️ XDR - Special Drawing Rights"
        XCTAssertEqual(xdrCurrencyTitle, mockXdrCurrencyTitle)
    }

    func testUnknownCurrency() {
        let unknownCurrency = CurrencySceneViewModelTests.nativeCurrency(identifier: "XYZ")
        let unknownCurrencyTitle = unknownCurrency?.title

        // unknown currency not supported, it's managed by Currency raw vlaue from primitives
        XCTAssertEqual(unknownCurrencyTitle, nil)
    }

    func testBitcoinCurrency() {
        let btcCurrency = CurrencySceneViewModelTests.nativeCurrency(identifier: "BTC")
        let btcCurrencyTitle = btcCurrency?.title

        /* not supported yet
         let mockBtcCurrencyTitle = "₿ BTC - Bitcoin"
         XCTAssertEqual(btcCurrencyTitle, mockBtcCurrencyTitle)
         */
        XCTAssertEqual(btcCurrencyTitle, nil)
    }
}

extension CurrencySceneViewModelTests {
    static func nativeCurrency(identifier: String.ID) -> Locale.Currency? {
        Currency.nativeCurrencies.first(where: { $0.identifier == identifier })
    }

    static func nativeCurrency(currency: Currency) -> Locale.Currency? {
        Currency.nativeCurrencies.first(where: { $0.identifier == currency.rawValue })
    }
}
