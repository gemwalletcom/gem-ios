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
struct StakeSceneViewModelTests {

    @Test
    func testAprValue() throws {
        #expect(StakeSceneViewModel.mock(stakeService: MockStakeService(stakeApr: 13.5)).stakeAprValue == "13.50%")
        #expect(StakeSceneViewModel.mock(stakeService: MockStakeService(stakeApr: 0)).stakeAprValue == .empty)
        #expect(StakeSceneViewModel.mock(stakeService: MockStakeService(stakeApr: .none)).stakeAprValue == .empty)
    }
    
    @Test
    func testLockTimeValue() throws {
        #expect(StakeSceneViewModel.mock(chain: .tron).lockTimeValue == "14 days")
    }
    
    @Test
    func minimumStakeAmount() throws {
        #expect(StakeSceneViewModel.mock(chain: .tron).minAmountValue == "1.00 TRX")
    }
    
    @Test
    func showManage() throws {
        #expect(StakeSceneViewModel.mock(wallet: .mock(type: .multicoin)).showManage == true)
        #expect(StakeSceneViewModel.mock(wallet: .mock(type: .view)).showManage == false)
    }
}

//TODO: Move to staking test kit
extension StakeSceneViewModel {
    static func mock(
        wallet: Wallet = .mock(),
        chain: Chain = .tron,
        stakeService: any StakeServiceable = MockStakeService(stakeApr: 13.5)
    ) -> StakeSceneViewModel {
        StakeSceneViewModel(
            wallet: wallet,
            chain: chain,
            stakeService: stakeService
        )
    }
}
