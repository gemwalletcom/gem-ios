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
}

extension AmountSceneViewModel {
    static func mock() -> AmountSceneViewModel {
        let db = DB.mockAssets()
        return AmountSceneViewModel(
            input: AmountInput(
                type: .transfer(recipient: .mock()),
                asset: .mockEthereum()
            ),
            wallet: .mock(),
            walletsService: .mock(balanceService: .mock(balanceStore: .mock(db: db))),
            stakeService: .mock(),
            onTransferAction: { _ in }
        )
    }
}
