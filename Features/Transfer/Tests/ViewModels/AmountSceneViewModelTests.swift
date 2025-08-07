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
}

extension AmountSceneViewModel {
    static func mock(
        type: AmountType = .transfer(recipient: .mock()),
        asset: Asset = .mockEthereum()
    ) -> AmountSceneViewModel {
        let balanceStore = BalanceStore.mock(db: .mockAssets())
        return AmountSceneViewModel(
            input: AmountInput(type: type, asset: asset),
            wallet: .mock(),
            amountService: AmountService(
                priceService: .mock(),
                balanceService:.mock(
                    balanceStore: balanceStore,
                    assetsService: .mock(balanceStore: balanceStore),
                    chainServiceFactory: .mock()
                ),
                stakeService: .mock()
            ),
            onTransferAction: { _ in
            }
        )
    }
}
