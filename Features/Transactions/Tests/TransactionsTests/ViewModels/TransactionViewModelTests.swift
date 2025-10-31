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
        let fromAsset = Asset.mockEthereum()
        let toAsset = Asset.mockEthereumUSDT()
        #expect(TransactionViewModel.mock(metadata: .swap(.mock(fromAsset: fromAsset.id, toAsset: toAsset.id, toValue: "1000000"))).subtitleTextValue?.text == "+1.00 USDT")
        #expect(TransactionViewModel.mock(metadata: .swap(.mock(fromAsset: fromAsset.id, toAsset: toAsset.id, toValue: "10000"))).subtitleTextValue?.text == "+0.01 USDT")
        #expect(TransactionViewModel.mock(metadata: .swap(.mock(fromAsset: fromAsset.id, toAsset: toAsset.id, toValue: "1000"))).subtitleTextValue?.text == "+0.001 USDT")
        #expect(TransactionViewModel.mock(metadata: .swap(.mock(fromAsset: fromAsset.id, toAsset: toAsset.id, toValue: "100"))).subtitleTextValue?.text == "+0.0001 USDT")
        #expect(TransactionViewModel.mock(metadata: .swap(.mock(fromAsset: fromAsset.id, toAsset: toAsset.id, toValue: "10"))).subtitleTextValue?.text == "+0.00001 USDT")
        #expect(TransactionViewModel.mock(metadata: .swap(.mock(fromAsset: fromAsset.id, toAsset: toAsset.id, toValue: "1"))).subtitleTextValue?.text == "+0.000001 USDT")
    }
    
    @Test
    func participant_returnsCorrectAddress() {
        let outgoingViewModel = TransactionViewModel.mock(
            type: .transfer,
            direction: .outgoing,
            participant: "to_address",
            metadata: .swap(.mock())
        )
        #expect(outgoingViewModel.participant == "to_address")

        let selfTransferViewModel = TransactionViewModel.mock(
            type: .transfer,
            direction: .selfTransfer,
            participant: "self_address",
            metadata: .swap(.mock())
        )
        #expect(selfTransferViewModel.participant == "self_address")
    }
    
    @Test
    func titleExtraUsesAddressNames() {
        let toAddress = AddressName.mock(address: "0x742d35cc6327c516e07e17dddaef8b48ca1e8c4a", name: "Hyperliquid")
        let hyperliquidViewModel = TransactionViewModel.mock(
            type: .transfer,
            direction: .outgoing,
            participant: "0x742d35cc6327c516e07e17dddaef8b48ca1e8c4a",
            toAddress: toAddress,
            metadata: .swap(.mock())
        )
        #expect(hyperliquidViewModel.titleExtraTextValue?.text.contains("Hyperliquid") == true)

        let fromAddress = AddressName.mock(address: "0x1111111111111111111111111111111111111111", name: "Sender")
        let incomingViewModel = TransactionViewModel.mock(
            type: .transfer,
            direction: .incoming,
            participant: "0x1111111111111111111111111111111111111111",
            fromAddress: fromAddress,
            metadata: .swap(.mock())
        )
        #expect(incomingViewModel.titleExtraTextValue?.text.contains("Sender") == true)

        let unknownViewModel = TransactionViewModel.mock(
            type: .transfer,
            direction: .outgoing,
            participant: "0x1234567890abcdef1234567890abcdef12345678",
            metadata: .swap(.mock())
        )
        #expect(unknownViewModel.titleExtraTextValue?.text.contains("0x1234") == true)
        #expect(unknownViewModel.titleExtraTextValue?.text.contains("5678") == true)
    }

    @Test
    func titleExtraPerpetualShowsPriceWithLabel() {
        let openPositionModel = TransactionViewModel.mock(
            type: .perpetualOpenPosition,
            asset: .hypercoreUSDC(),
            metadata: .perpetual(.mock(price: 50000.50))
        )
        #expect(openPositionModel.titleExtraTextValue?.text == "Price: $50,000.50")

        let closePositionModel = TransactionViewModel.mock(
            type: .perpetualClosePosition,
            asset: .hypercoreUSDC(),
            metadata: .perpetual(.mock(price: 49999.99))
        )
        #expect(closePositionModel.titleExtraTextValue?.text == "Price: $49,999.99")
    }

    @Test
    func subtitlePerpetualOpenPositionShowsFiatValue() {
        let model = TransactionViewModel.mock(
            type: .perpetualOpenPosition,
            value: "1000000",
            asset: .hypercoreUSDC(),
            metadata: .perpetual(.mock())
        )
        #expect(model.subtitleTextValue?.text == "$1.00")
    }

    @Test
    func subtitlePerpetualClosePositionShowsPnl() {
        let profitModel = TransactionViewModel.mock(
            type: .perpetualClosePosition,
            asset: .hypercoreUSDC(),
            metadata: .perpetual(.mock(pnl: 125.50))
        )
        #expect(profitModel.subtitleTextValue?.text == "+$125.50")

        let lossModel = TransactionViewModel.mock(
            type: .perpetualClosePosition,
            asset: .hypercoreUSDC(),
            metadata: .perpetual(.mock(pnl: -75.25))
        )
        #expect(lossModel.subtitleTextValue?.text == "-$75.25")
    }

    @Test
    func subtitlePerpetualClosePositionNoPnl() {
        let model = TransactionViewModel.mock(
            type: .perpetualClosePosition,
            asset: .hypercoreUSDC(),
            metadata: .perpetual(.mock(pnl: 0))
        )
        #expect(model.subtitleTextValue == nil)
    }

    func testTransactionTitle(expectedTitle: String, transaction: Transaction) {
        #expect(TransactionViewModel(explorerService: MockExplorerLink(), transaction: .mock(transaction: transaction), currency: "USD").titleTextValue.text == expectedTitle)
    }
}

extension TransactionViewModel {
    static func mock(
        type: TransactionType = .swap,
        state: TransactionState = .confirmed,
        direction: TransactionDirection = .incoming,
        participant: String = "",
        memo: String? = nil,
        fromAddress: AddressName? = nil,
        toAddress: AddressName? = nil,
        value: String = "1000000000000000000",
        asset: Asset = .mockEthereum(),
        assets: [Asset] = [.mockEthereum(), .mockEthereumUSDT()],
        metadata: TransactionMetadata
    ) -> TransactionViewModel {
        let transaction = Transaction.mock(
            type: type,
            state: state,
            direction: direction,
            to: participant,
            value: value,
            memo: memo,
            metadata: metadata
        )
        let extended = TransactionExtended.mock(
            transaction: transaction,
            asset: asset,
            assets: assets,
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
