import Testing
import Primitives
import Style

@testable import Transactions

struct TransactionPnlViewModelTests {

    @Test
    func positivePnl() {
        if case .pnl(_, let value, let color) = TransactionPnlViewModel(metadata: .perpetual(.mock(pnl: 100))).itemModel {
            #expect(value.contains("+"))
            #expect(color == Colors.green)
        } else {
            Issue.record("Expected pnl item")
        }
    }

    @Test
    func negativePnl() {
        if case .pnl(_, let value, let color) = TransactionPnlViewModel(metadata: .perpetual(.mock(pnl: -50))).itemModel {
            #expect(value.contains("-"))
            #expect(color == Colors.red)
        } else {
            Issue.record("Expected pnl item")
        }
    }

    @Test
    func zeroPnl() {
        if case .empty = TransactionPnlViewModel(metadata: .perpetual(.mock(pnl: 0))).itemModel {
        } else {
            Issue.record("Expected empty")
        }
    }

    @Test
    func nonPerpetualMetadata() {
        if case .empty = TransactionPnlViewModel(metadata: nil).itemModel {
        } else {
            Issue.record("Expected empty")
        }
    }
}
