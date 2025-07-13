// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import PrimitivesTestKit
import PrimitivesComponents
import Primitives

@testable import Transactions

final class TransactionViewModelTests {

    @Test
    func testTransactionTitle() {
        testTransactionTitle(expectedTitle: "Received", transaction: .mock(state: .confirmed))
        testTransactionTitle(expectedTitle: "Sent", transaction: .mock(state: .confirmed, direction: .outgoing))
        testTransactionTitle(expectedTitle: "Transfer", transaction: .mock(state: .failed))
        testTransactionTitle(expectedTitle: "Swap", transaction: .mock(type: .swap))
    }
    
    @Test
    func testAutoValueFormatter() {
        #expect(TransactionViewModel.mock(toValue: "1000000").subtitle == "+1.00 USDT")
        #expect(TransactionViewModel.mock(toValue: "10000").subtitle == "+0.01 USDT")
        #expect(TransactionViewModel.mock(toValue: "1000").subtitle == "+0.001 USDT")
        #expect(TransactionViewModel.mock(toValue: "100").subtitle == "+0.0001 USDT")
        #expect(TransactionViewModel.mock(toValue: "10").subtitle == "+0.00001 USDT")
        #expect(TransactionViewModel.mock(toValue: "1").subtitle == "+0.000001 USDT")
    }

    func testTransactionTitle(expectedTitle: String, transaction: Transaction) {
        #expect(TransactionViewModel(explorerService: MockExplorerLink(), transaction: .mock(transaction: transaction), formatter: .full).title == expectedTitle)
    }
}

extension TransactionViewModel {
    static func mock(
        fromValue: String = "",
        toValue: String = "",
        type: TransactionType = .swap,
        direction: TransactionDirection = .incoming,
        participant: String = "",
        memo: String? = nil
    ) -> TransactionViewModel {
        let fromAsset = Asset.mockEthereum()
        let toAsset = Asset.mockEthereumUSDT()

        let swapMetadata = TransactionMetadata.swap(
            TransactionSwapMetadata(
                fromAsset: fromAsset.id,
                fromValue: fromValue,
                toAsset: toAsset.id,
                toValue: toValue,
                provider: ""
            )
        )
        
        let transaction = Transaction.mock(
            type: type,
            direction: direction,
            to: participant,
            value: "1000000000000000000",
            memo: memo,
            metadata: swapMetadata
        )
        let extended = TransactionExtended.mock(
            transaction: transaction,
            asset: fromAsset,
            assets: [fromAsset, toAsset]
        )

        return TransactionViewModel(
            explorerService: MockExplorerLink(),
            transaction: extended,
            formatter: .auto
        )
    }
}
