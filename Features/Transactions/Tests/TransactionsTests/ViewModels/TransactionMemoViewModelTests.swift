// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import PrimitivesTestKit
import Primitives

@testable import Transactions

struct TransactionMemoViewModelTests {

    @Test
    func itemModelEmpty_whenChainDoesNotSupportMemo() {
        let model = TransactionMemoViewModel(transaction: .mock(assetId: .mockEthereum(), memo: "test"))

        if case .empty = model.itemModel {} else {
            Issue.record("Expected .empty")
        }
    }

    @Test
    func itemModelEmpty_whenMemoIsEmpty() {
        #expect(matches(TransactionMemoViewModel(transaction: .mock(assetId: .mock(.cosmos), memo: nil))))
        #expect(matches(TransactionMemoViewModel(transaction: .mock(assetId: .mock(.cosmos), memo: ""))))
    }

    @Test
    func itemModelListItem_whenMemoIsSupported() {
        let model = TransactionMemoViewModel(transaction: .mock(assetId: .mock(.cosmos), memo: "test memo"))

        if case .listItem = model.itemModel {} else {
            Issue.record("Expected .listItem")
        }
    }

    private func matches(_ model: TransactionMemoViewModel) -> Bool {
        if case .empty = model.itemModel { return true }
        return false
    }
}
