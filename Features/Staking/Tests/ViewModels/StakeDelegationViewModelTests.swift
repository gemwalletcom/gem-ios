// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import Staking
import PrimitivesTestKit
import Primitives

struct StakeDelegationViewModelTests {

    @Test
    func balance() {
        #expect(StakeDelegationViewModel.mock().balanceText == "1,500.00 TRX")
        #expect(StakeDelegationViewModel.mock().balanceFiatValueText == "$3,000.00")
    }
    
    @Test
    func rewards() {
        #expect(StakeDelegationViewModel.mock().rewardsText == "500.00 TRX")
        #expect(StakeDelegationViewModel.mock().rewardsFiatValueText == "$1,000.00")
    }
    
    @Test
    func subtitleExtraTextWithCompletion() {
        let viewModel = StakeDelegationViewModel.mock(state: .undelegating, completionDate: Date.now.addingTimeInterval(86400))

        #expect(viewModel.subtitleExtraText == viewModel.completionDateText)
    }
}

extension StakeDelegationViewModel {
    static func mock(
        state: DelegationState = .active,
        completionDate: Date? = nil
    ) -> StakeDelegationViewModel {
        StakeDelegationViewModel(delegation: .mock(
            state: state,
            price: Price.mock(price: 2.0),
            base: .mock(
                state: state,
                assetId: .mock(.tron),
                balance: "1500000000",
                rewards: "500000000",
                completionDate: completionDate
            )
        ))
    }
}
