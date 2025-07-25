// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import PrimitivesTestKit
import Primitives
import StakeService
import StakeServiceTestKit

@testable import Staking

struct StakeDetailViewModelTests {

    @Test
    func testWithdrawStakeTransferData() throws {
        let delegation = Delegation.mock(state: .awaitingWithdrawal)
        let model = StakeDetailViewModel.mock(delegation: delegation)

        let transferData = try model.withdrawStakeTransferData()

        #expect(transferData.canChangeValue == false)
        #expect(transferData.ignoreValueCheck == true)
        #expect(transferData.type.shouldIgnoreValueCheck == true)
        #expect(transferData.value == delegation.base.balanceValue)
        #expect(transferData.recipientData.recipient.address == delegation.validator.id)
        #expect(transferData.recipientData.recipient.name == delegation.validator.name)
    }
}

extension StakeDetailViewModel {
    static func mock(delegation: Delegation) -> StakeDetailViewModel {
        StakeDetailViewModel(
            wallet: .mock(),
            model: StakeDelegationViewModel(delegation: delegation),
            service: .mock(),
            onAmountInputAction: .none,
            onTransferAction: .none
        )
    }
}
