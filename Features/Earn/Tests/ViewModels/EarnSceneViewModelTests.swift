// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import Store
import StakeService
import StakeServiceTestKit
import PrimitivesTestKit
import Primitives
import EarnService
import EarnServiceTestKit

@testable import Earn

@MainActor
struct EarnSceneViewModelTests {

    @Test
    func testAprValue() throws {
        #expect(EarnSceneViewModel.mock(stakeService: MockStakeService(stakeApr: 13.5)).stakeAprValue == "13.50%")
        #expect(EarnSceneViewModel.mock(stakeService: MockStakeService(stakeApr: 0)).stakeAprValue == .empty)
        #expect(EarnSceneViewModel.mock(stakeService: MockStakeService(stakeApr: .none)).stakeAprValue == .empty)
    }

    @Test
    func testLockTimeValue() throws {
        #expect(EarnSceneViewModel.mock(chain: .tron).lockTimeValue == "14 days")
    }

    @Test
    func minimumStakeAmount() throws {
        #expect(EarnSceneViewModel.mock(chain: .tron).minAmountValue == "1.00 TRX")
    }

    @Test
    func showManage() throws {
        #expect(EarnSceneViewModel.mock(wallet: .mock(type: .multicoin)).showManage == true)
        #expect(EarnSceneViewModel.mock(wallet: .mock(type: .view)).showManage == false)
    }
}

extension EarnSceneViewModel {
    static func mock(
        wallet: Wallet = .mock(),
        chain: StakeChain = .tron,
        stakeService: any StakeServiceable = MockStakeService(stakeApr: 13.5),
        yieldService: YieldService = .mock(),
        earnPositionsService: any EarnBalanceServiceable = MockEarnBalanceService(),
        earnAsset: Asset = .mockTron()
    ) -> EarnSceneViewModel {
        EarnSceneViewModel(
            wallet: wallet,
            chain: chain,
            stakeService: stakeService,
            yieldService: yieldService,
            earnPositionsService: earnPositionsService,
            earnAsset: earnAsset
        )
    }
}
