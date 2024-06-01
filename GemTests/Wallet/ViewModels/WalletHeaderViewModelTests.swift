import XCTest
@testable import Gem
import Primitives

final class WalletHeaderViewModelTests: XCTestCase {

    let value = WalletFiatValue(totalValue: 1000, price: 120, priceChangePercentage24h: 100)

    func testTotalValue() {
        XCTAssertEqual(WalletHeaderViewModel(walletModel: WalletViewModel(wallet: .main), value: value).totalValueText, "$1,000.00")
    }

    func testTotalPrice() {
        let value = WalletFiatValue(totalValue: 1000, price: 120, priceChangePercentage24h: 100)

        XCTAssertEqual(WalletHeaderViewModel(walletModel: WalletViewModel(wallet: .main), value: value).totalPrice, "+$120.00")
    }

    func testTotalPriceChaneg() {
        let value = WalletFiatValue(totalValue: 1000, price: 120, priceChangePercentage24h: 100)

        XCTAssertEqual(WalletHeaderViewModel(walletModel: WalletViewModel(wallet: .main), value: value).totalPriceChange, "+100.00%")
    }
}
