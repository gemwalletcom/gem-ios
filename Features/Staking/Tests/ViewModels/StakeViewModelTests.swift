// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import Store
import StakeService
import StakeServiceTestKit
import PrimitivesTestKit
import Primitives

@testable import Staking

@MainActor
struct StakeViewModelTests {

    @Test
    func testAprValue() throws {
        #expect(StakeViewModel.mock(stakeService: MockStakeService(stakeApr: 13.5)).stakeAprValue == "13.50%")
        #expect(StakeViewModel.mock(stakeService: MockStakeService(stakeApr: 0)).stakeAprValue == .empty)
        #expect(StakeViewModel.mock(stakeService: MockStakeService(stakeApr: .none)).stakeAprValue == .empty)
    }
    
    @Test
    func testLockTimeValue() throws {
        #expect(StakeViewModel.mock(chain: .tron).lockTimeValue == "14 days")
    }
    
    @Test
    func minimumStakeAmount() throws {
        #expect(StakeViewModel.mock(chain: .tron).minAmountValue == "1.00 TRX")
    }
}

//TODO: Move to staking test kit
extension StakeViewModel {
    static func mock(
        chain: Chain = .tron,
        stakeService: any StakeServiceable = MockStakeService(stakeApr: 13.5)
    ) -> StakeViewModel {
        StakeViewModel(
            wallet: .mock(),
            chain: chain,
            stakeService: stakeService,
            onTransferAction: .none,
            onAmountInputAction: .none
        )
    }
}
