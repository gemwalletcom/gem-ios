// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import WalletsServiceTestKit
import StakeServiceTestKit
import PrimitivesTestKit
import BalanceServiceTestKit
import PriceServiceTestKit
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

    @Test
    func depositTitle() {
        #expect(AmountSceneViewModel.mock(type: .deposit(recipient: .mock())).title == "Deposit")
    }
    
    @Test
    func stakingReservedFeesText() {
        let assetData = AssetData.mock(asset: .mockBNB(), balance: .mock(available: 2_000_000_000_000_000_000))
        let model = AmountSceneViewModel.mock(type: .stake(validators: [], recommendedValidator: nil), assetData: assetData)
        
        model.onSelectMaxButton()

        #expect(model.infoText != nil)
        #expect(model.amountInputModel.text == "1.99975")
        
        model.amountInputModel.text = .zero
        #expect(model.infoText == nil)
    }
    
//    @Test
//    func depositMinimumAmount() {
//        let usdcAsset = Asset.mock(
//            id: AssetId(chain: .ethereum, tokenId: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"),
//            symbol: "USDC",
//            decimals: 6
//        )
//        let model = AmountSceneViewModel.mock(type: .deposit(recipient: .mock()), asset: usdcAsset)
//        
//        model.amountInputModel.update(text: "4.99")
//        let _ = model.amountInputModel.validate()
//        #expect(!model.amountInputModel.isValid)
//        
//        model.amountInputModel.update(text: "5")
//        let _ = model.amountInputModel.validate()
//        #expect(model.amountInputModel.isValid)
//    }

    @Test
    func transferWithSmallAmount() {
        let assetData = AssetData.mock(asset: .mockBNB(), balance: .mock(available: 10_000_000_000_000_000))
        let model = AmountSceneViewModel.mock(type: .transfer(recipient: .mock()), assetData: assetData)

        model.amountInputModel.update(text: "0.001")
        #expect(model.amountInputModel.isValid)
    }

    @Test
    func stakeWithInsufficientAmount() {
        let assetData = AssetData.mock(asset: .mockBNB(), balance: .mock(available: 2_000_000_000_000_000_000))
        let model = AmountSceneViewModel.mock(type: .stake(validators: [], recommendedValidator: nil), assetData: assetData)

        model.amountInputModel.update(text: "0.099")
        #expect(model.amountInputModel.isValid == false)
    }

    @Test
    func stakeWithSufficientAmount() {
        let assetData = AssetData.mock(asset: .mockBNB(), balance: .mock(available: 5_000_000_000_000_000_000))
        let model = AmountSceneViewModel.mock(type: .stake(validators: [], recommendedValidator: nil), assetData: assetData)

        model.amountInputModel.update(text: "1.5")
        #expect(model.amountInputModel.isValid == true)
    }

    @Test
    func stakeManualInputNearMax() {
        let assetData = AssetData.mock(asset: .mockBNB(), balance: .mock(available: 2_000_000_000_000_000_000))
        let model = AmountSceneViewModel.mock(type: .stake(validators: [], recommendedValidator: nil), assetData: assetData)

        model.amountInputModel.update(text: "2.0")
        #expect(model.infoText != nil)

        model.amountInputModel.update(text: "1.9")
        #expect(model.infoText == nil)
    }

    @Test
    func stakeUserInputAboveMax() {
        let assetData = AssetData.mock(asset: .mockBNB(), balance: .mock(available: 2_000_000_000_000_000_000))
        let model = AmountSceneViewModel.mock(type: .stake(validators: [.mock()], recommendedValidator: .mock()), assetData: assetData)

        model.amountInputModel.update(text: "2.0")
        #expect(model.infoText != nil)
        #expect(model.amountInputModel.isValid == true)
    }

    @Test
    func stakeWithInsufficientBalanceForFees() {
        let assetData = AssetData.mock(asset: .mockBNB(), balance: .mock(available: 1_000_200_000_000_000_000))
        let model = AmountSceneViewModel.mock(type: .stake(validators: [], recommendedValidator: nil), assetData: assetData)

        model.amountInputModel.update(text: "1.0")
        #expect(model.amountInputModel.isValid == false)
    }

    @Test
    func freezeWithInsufficientBalanceForFees() {
        let assetData = AssetData.mock(asset: .mockTron(), balance: .mock(available: 1_002_000))
        let model = AmountSceneViewModel.mock(
            type: .freeze(data: .init(freezeType: .freeze, resource: .bandwidth)),
            assetData: assetData
        )

        model.amountInputModel.update(text: "1.0")
        #expect(model.amountInputModel.isValid == false)
    }

    @Test
    func unfreezeWithSufficientBalance() {
        let assetData = AssetData.mock(asset: .mockTron(), balance: .mock(frozen: 1_000_000))
        let model = AmountSceneViewModel.mock(
            type: .freeze(data: .init(freezeType: .unfreeze, resource: .bandwidth)),
            assetData: assetData
        )

        model.amountInputModel.update(text: "1.0")
        #expect(model.amountInputModel.isValid == true)
    }

    @Test
    func unfreezeEnergyWithSufficientBalance() {
        let assetData = AssetData.mock(asset: .mockTron(), balance: .mock(locked: 2_000_000))
        let model = AmountSceneViewModel.mock(
            type: .freeze(data: .init(freezeType: .unfreeze, resource: .energy)),
            assetData: assetData
        )

        model.amountInputModel.update(text: "2.0")
        #expect(model.amountInputModel.isValid == true)
    }

    @Test
    func tronStakeWithoutFeeReservation() {
        let assetData = AssetData.mock(asset: .mockTron(), balance: .mock(frozen: 10_000_000, locked: 0))
        let model = AmountSceneViewModel.mock(type: .stake(validators: [], recommendedValidator: nil), assetData: assetData)

        model.amountInputModel.update(text: "10")
        #expect(model.amountInputModel.isValid == true)
    }
}

extension AmountSceneViewModel {
    static func mock(
        type: AmountType = .transfer(recipient: .mock()),
        assetData: AssetData = .mock(balance: .mock())
    ) -> AmountSceneViewModel {
        let model = AmountSceneViewModel(
            input: AmountInput(type: type, asset: assetData.asset),
            wallet: .mock(),
            onTransferAction: { _ in }
        )
        model.assetData = assetData
        model.onChangeAssetBalance(assetData, assetData)
        return model
    }
}
