import Testing
import Primitives

@testable import Gem

struct WalletHeaderViewModelTests {

    @Test
    func testTotalValue() {
        #expect(WalletHeaderViewModel(walletType: .multicoin, value: 1000).totalValueText == "$1,000.00")
    }
}
