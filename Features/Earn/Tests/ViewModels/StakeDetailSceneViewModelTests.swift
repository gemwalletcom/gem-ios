// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import StakeService
import StakeServiceTestKit
import PrimitivesTestKit
import Primitives

@testable import Earn

struct StakeDetailSceneViewModelTests {

    @Test
    func showManage() {
        #expect(StakeDetailSceneViewModel.mock(wallet: .mock(type: .multicoin)).showManage == true)
        #expect(StakeDetailSceneViewModel.mock(wallet: .mock(type: .view)).showManage == false)
    }
}

extension StakeDetailSceneViewModel {
    static func mock(
        wallet: Wallet = .mock(),
        model: StakeDelegationViewModel = StakeDelegationViewModel.mock(),
        service: any StakeServiceable = MockStakeService()
    ) -> StakeDetailSceneViewModel {
        StakeDetailSceneViewModel(
            wallet: wallet,
            model: model,
            service: service,
            onAmountInputAction: nil,
            onTransferAction: nil
        )
    }
}

