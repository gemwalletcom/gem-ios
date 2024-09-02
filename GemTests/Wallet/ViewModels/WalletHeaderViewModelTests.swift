import XCTest
@testable import Gem
import Primitives

final class WalletHeaderViewModelTests: XCTestCase {

    func testTotalValue() {
        XCTAssertEqual(WalletHeaderViewModel(walletType: .multicoin, value: 1000).totalValueText, "$1,000.00")
    }
}
