// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import PrimitivesTestKit
import Primitives

@testable import Stake

struct DelegationDetailSceneViewModelTests {

    @Test
    func showManage() {
        #expect(DelegationDetailSceneViewModel.mock(wallet: .mock(type: .multicoin)).showManage == true)
        #expect(DelegationDetailSceneViewModel.mock(wallet: .mock(type: .view)).showManage == false)
    }
}

extension DelegationDetailSceneViewModel {
    static func mock(
        wallet: Wallet = .mock(),
        model: DelegationViewModel = .mock(),
        validators: [DelegationValidator] = []
    ) -> DelegationDetailSceneViewModel {
        DelegationDetailSceneViewModel(
            wallet: wallet,
            model: model,
            asset: model.delegation.base.assetId.chain.asset,
            validators: validators,
            onAmountInputAction: nil,
            onTransferAction: nil
        )
    }
}
