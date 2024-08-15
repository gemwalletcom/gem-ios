// Copyright (c). Gem Wallet. All rights reserved.

import XCTest
@testable import Gem
import PrimitivesTestKit

final class TransactionViewModelTests: XCTestCase {

    func testTransactionTitle() {
        XCTAssertEqual(
            TransactionViewModel(transaction: .mock(transaction: .mock(state: .confirmed)), formatter: .full).title,
            "Received"
        )
        XCTAssertEqual(
            TransactionViewModel(transaction: .mock(transaction: .mock(state: .confirmed, direction: .outgoing)), formatter: .full).title,
            "Sent"
        )
        XCTAssertEqual(
            TransactionViewModel(transaction: .mock(transaction: .mock(state: .failed)), formatter: .full).title,
            "Transfer"
        )
        XCTAssertEqual(
            TransactionViewModel(transaction: .mock(transaction: .mock(type: .swap)), formatter: .full).title,
            "Swap"
        )
    }
}
