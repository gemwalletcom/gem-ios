import Testing
import Primitives

@testable import PrimitivesComponents

struct WalletHeaderViewModelTests {

    @Test
    func testTotalValue() {
        #expect(
            WalletHeaderViewModel(
                walletType: .multicoin,
                value: 1000,
                currencyCode: Currency.usd.rawValue)
            .totalValueText == "$1,000.00"
        )
    }
}
