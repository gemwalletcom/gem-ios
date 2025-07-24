// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import WalletsServiceTestKit
import StakeServiceTestKit
import PrimitivesTestKit
import Primitives
import Store

@testable import Transfer

@MainActor
struct AmountSceneViewModelTests {
    
    @Test
    func testMaxButton() {
        let model = AmountSceneViewModel.mock()
        
        #expect(model.amountInputModel.isValid)
        
        model.onSelectMaxButton()
        #expect(model.amountInputModel.isValid)
        
        model.onSelectInputButton()
        model.onSelectMaxButton()
        #expect(model.amountInputModel.isValid)
    }
    
    func depositTitle() {
        let model = AmountSceneViewModel.mockDeposit()
        #expect(model.title == "Deposit")
    }
    
    func depositMinimumAmount() {
        let model = AmountSceneViewModel.mockDepositUSDC()
        
        model.amountInputModel.update(text: "4.99")
        model.amountInputModel.validate()
        #expect(!model.amountInputModel.isValid)
        
        model.amountInputModel.update(text: "5")
        model.amountInputModel.validate()
        #expect(model.amountInputModel.isValid)
        
        model.amountInputModel.update(text: "10")
        model.amountInputModel.validate()
        #expect(model.amountInputModel.isValid)
    }
}

extension AmountSceneViewModel {
    static func mock() -> AmountSceneViewModel {
        AmountSceneViewModel(
            input: AmountInput(
                type: .transfer(recipient: .mock()),
                asset: .mockEthereum()
            ),
            wallet: .mock(),
            walletsService: .mock(balanceService: .mock(balanceStore: .mock(db: DB.mockAssets()))),
            stakeService: .mock(),
            onTransferAction: { _ in }
        )
    }
    
    static func mockDeposit() -> AmountSceneViewModel {
        AmountSceneViewModel(
            input: AmountInput(
                type: .deposit(recipient: .mock()),
                asset: .mockEthereum()
            ),
            wallet: .mock(),
            walletsService: .mock(balanceService: .mock(balanceStore: .mock(db: DB.mockAssets()))),
            stakeService: .mock(),
            onTransferAction: { _ in }
        )
    }
    
    static func mockDepositUSDC() -> AmountSceneViewModel {
        let usdcAssetId = AssetId(chain: .ethereum, tokenId: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48")
        let usdcAsset = Asset.mock(id: usdcAssetId, symbol: "USDC", decimals: 6)
        return AmountSceneViewModel(
            input: AmountInput(
                type: .deposit(recipient: .mock()),
                asset: usdcAsset
            ),
            wallet: .mock(),
            walletsService: .mock(balanceService: .mock(balanceStore: .mock(db: DB.mockAssets()))),
            stakeService: .mock(),
            onTransferAction: { _ in }
        )
    }
}
