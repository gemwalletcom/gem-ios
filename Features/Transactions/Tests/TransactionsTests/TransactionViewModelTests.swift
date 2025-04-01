// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import PrimitivesTestKit
import PrimitivesComponents
import Primitives

@testable import Gem

final class TransactionViewModelTests {

    @Test
    func testTransactionTitle() {
        testTransactionTitle(expectedTitle: "Received", transaction: .mock(state: .confirmed))
        testTransactionTitle(expectedTitle: "Sent", transaction: .mock(state: .confirmed, direction: .outgoing))
        testTransactionTitle(expectedTitle: "Transfer", transaction: .mock(state: .failed))
        testTransactionTitle(expectedTitle: "Swap", transaction: .mock(type: .swap))
    }

    func testTransactionTitle(expectedTitle: String, transaction: Transaction) {
        #expect(TransactionViewModel(explorerService: MockExplorerLink(), transaction: .mock(transaction: transaction), formatter: .full).title == expectedTitle)
    }
}
