// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import BigInt
import Preferences
import PrimitivesTestKit
import Validators

@testable import Transfer

struct TransactionInputViewModelTests {
    @Test
    func testValueWithAmount() {
        let viewModel = TransactionInputViewModel(
            data: .mock(),
            transactionData: nil,
            metaData: nil,
            transferAmountResult: .amount(TransferAmount(value: 200, networkFee: 1, useMaxAmount: false))
        )
        
        #expect(viewModel.value == BigInt(200))
    }
    
    @Test
    func testValueWithError() {
        let viewModel = TransactionInputViewModel(
            data: .mock(),
            transactionData: nil,
            metaData: nil,
            transferAmountResult: .error(nil, TransferAmountCalculatorError.insufficientBalance(.mock()))
        )
        
        #expect(viewModel.value == BigInt(100))
    }
    
    @Test
    func testValueWithNilResult() {
        let viewModel = TransactionInputViewModel(
            data: .mock(),
            transactionData: nil,
            metaData: nil,
            transferAmountResult: nil
        )
        
        #expect(viewModel.value == BigInt(100))
    }
    
    @Test
    func testNetworkFeeText() {
        let viewModel = TransactionInputViewModel(
            data: .mock(),
            transactionData: .mock(),
            metaData: nil,
            transferAmountResult: nil
        )
        
        #expect(viewModel.networkFeeText == "0.00000001 BTC")
    }
    
    @Test
    func testNetworkFeeFiatText() {
        let metaData = TransferDataMetadata(
            assetId: .mock(),
            feeAssetId: .mock(),
            assetBalance: .zero,
            assetFeeBalance: .zero,
            assetPrices: [.mock():.mock()]
        )
        let viewModel = TransactionInputViewModel(
            data: .mock(),
            transactionData: .mock(),
            metaData: metaData,
            transferAmountResult: nil
        )
        
        #expect(viewModel.networkFeeFiatText == "$0.000000015")
    }
    
    @Test
    func testNilFee() {
        let viewModel = TransactionInputViewModel(
            data: .mock(),
            transactionData: nil,
            metaData: nil,
            transferAmountResult: nil
        )
        
        #expect(viewModel.networkFeeText == "-")
        #expect(viewModel.networkFeeFiatText == nil)
    }
}

extension TransferData {
    static func mock() -> TransferData {
        TransferData(
            type: .transfer(.mock()),
            recipientData: .mock(),
            value: BigInt(100),
            canChangeValue: true
        )
    }
}

extension TransactionData {
    static func mock() -> TransactionData {
        TransactionData(
            fee: Fee(
                fee: 1,
                gasPriceType: .regular(gasPrice: 1),
                gasLimit: 1
            )
        )
    }
}
