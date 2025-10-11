import Testing
import Primitives

@testable import Transactions

struct TransactionPriceViewModelTests {

    @Test
    func priceValue() {
        if case .price(_, let value) = TransactionPriceViewModel(metadata: .perpetual(.mock(price: 50000))).itemModel {
            #expect(value.contains("50"))
        } else {
            Issue.record("Expected price item")
        }
    }

    @Test
    func zeroPrice() {
        if case .empty = TransactionPriceViewModel(metadata: .perpetual(.mock(price: 0))).itemModel {
        } else {
            Issue.record("Expected empty")
        }
    }

    @Test
    func nonPerpetualMetadata() {
        if case .empty = TransactionPriceViewModel(metadata: nil).itemModel {
        } else {
            Issue.record("Expected empty")
        }
    }
}
