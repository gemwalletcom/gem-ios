// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import Staking
import PrimitivesTestKit
import Primitives

struct StakeDelegationViewModelTests {

    @Test
    func balance() {
        let model = StakeDelegationViewModel.mock()

        #expect(model.balanceText == "1,500.00 TRX")
        #expect(model.fiatValueText == "$3,000.00")
    }
    
    @Test
    func rewards() {
        let model = StakeDelegationViewModel.mock()

        #expect(model.rewardsText == "500.00 TRX")
        #expect(model.rewardsFiatValueText == "$1,000.00")
    }
    
    @Test
    func completionDate() {
        #expect(
            StakeDelegationViewModel
                .mock(
                    state: .deactivating,
                    completionDate: Date.now.addingTimeInterval(86400)
                ).completionDateText == "23 hours, 59 minutes"
        )
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
