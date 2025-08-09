// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import PrimitivesTestKit
import PrimitivesComponents
import Primitives

@testable import Transactions

final class TransactionViewModelTests {

    @Test
    func transactionTitle() {
        testTransactionTitle(expectedTitle: "Received", transaction: .mock(state: .confirmed))
        testTransactionTitle(expectedTitle: "Sent", transaction: .mock(state: .confirmed, direction: .outgoing))
        testTransactionTitle(expectedTitle: "Transfer", transaction: .mock(state: .failed))
        testTransactionTitle(expectedTitle: "Swap", transaction: .mock(type: .swap))
    }
    
    @Test
    func autoValueFormatter() {
        #expect(TransactionViewModel.mock(toValue: "1000000").subtitleTextValue?.text == "+1.00 USDT")
        #expect(TransactionViewModel.mock(toValue: "10000").subtitleTextValue?.text == "+0.01 USDT")
        #expect(TransactionViewModel.mock(toValue: "1000").subtitleTextValue?.text == "+0.001 USDT")
        #expect(TransactionViewModel.mock(toValue: "100").subtitleTextValue?.text == "+0.0001 USDT")
        #expect(TransactionViewModel.mock(toValue: "10").subtitleTextValue?.text == "+0.00001 USDT")
        #expect(TransactionViewModel.mock(toValue: "1").subtitleTextValue?.text == "+0.000001 USDT")
    }
    
    @Test
    func participant_returnsCorrectAddress() {
        // Test outgoing transaction - should return 'to' address  
        let outgoingViewModel = TransactionViewModel.mock(type: .transfer, direction: .outgoing, participant: "to_address")
        #expect(outgoingViewModel.participant == "to_address")
        
        // Test self transfer - should return 'to' address
        let selfTransferViewModel = TransactionViewModel.mock(type: .transfer, direction: .selfTransfer, participant: "self_address")
        #expect(selfTransferViewModel.participant == "self_address")
    }
    
    @Test
    func titleExtraUsesAddressNames() {
        // Test with outgoing transaction - should use toAddress
        let toAddress = AddressName.mock(address: "0x742d35cc6327c516e07e17dddaef8b48ca1e8c4a", name: "Hyperliquid")
        let hyperliquidViewModel = TransactionViewModel.mock(
            type: .transfer, 
            direction: .outgoing, 
            participant: "0x742d35cc6327c516e07e17dddaef8b48ca1e8c4a",
            toAddress: toAddress
        )
        #expect(hyperliquidViewModel.titleExtraTextValue?.text.contains("Hyperliquid") == true)
        
        // Test with incoming transaction - should use fromAddress
        let fromAddress = AddressName.mock(address: "0x1111111111111111111111111111111111111111", name: "Sender")
        let incomingViewModel = TransactionViewModel.mock(
            type: .transfer,
            direction: .incoming,
            participant: "0x1111111111111111111111111111111111111111",
            fromAddress: fromAddress
        )
        #expect(incomingViewModel.titleExtraTextValue?.text.contains("Sender") == true)
        
        // Test with unknown address - should use formatted address
        let unknownViewModel = TransactionViewModel.mock(
            type: .transfer,
            direction: .outgoing,
            participant: "0x1234567890abcdef1234567890abcdef12345678"
        )
        #expect(unknownViewModel.titleExtraTextValue?.text.contains("0x1234") == true)
        #expect(unknownViewModel.titleExtraTextValue?.text.contains("5678") == true)
    }

    func testTransactionTitle(expectedTitle: String, transaction: Transaction) {
        #expect(TransactionViewModel(explorerService: MockExplorerLink(), transaction: .mock(transaction: transaction), currency: "USD").titleTextValue.text == expectedTitle)
    }
}

extension TransactionViewModel {
    static func mock(
        fromValue: String = "",
        toValue: String = "",
        type: TransactionType = .swap,
        state: TransactionState = .confirmed,
        direction: TransactionDirection = .incoming,
        participant: String = "",
        memo: String? = nil,
        fromAddress: AddressName? = nil,
        toAddress: AddressName? = nil
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
            state: state,
            direction: direction,
            to: participant,
            value: "1000000000000000000",
            memo: memo,
            metadata: swapMetadata
        )
        let extended = TransactionExtended.mock(
            transaction: transaction,
            asset: fromAsset,
            assets: [fromAsset, toAsset],
            fromAddress: fromAddress,
            toAddress: toAddress
        )

        return TransactionViewModel(
            explorerService: MockExplorerLink(),
            transaction: extended,
            currency: "USD"
        )
    }
}
