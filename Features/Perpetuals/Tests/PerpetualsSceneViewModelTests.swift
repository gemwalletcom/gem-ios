// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import PrimitivesTestKit
import PerpetualService
import PerpetualServiceTestKit
import ActivityService
import ActivityServiceTestKit
import PerpetualsTestKit
@testable import Perpetuals

@MainActor
struct PerpetualsSceneViewModelTests {

    @Test
    func headerViewModel() {
        let wallet = Wallet.mock(type: .multicoin)
        let model = PerpetualsSceneViewModel.mock(wallet: wallet)

        #expect(model.headerViewModel.walletType == .multicoin)
    }
}

extension PerpetualsSceneViewModel {
    @MainActor
    static func mock(
        wallet: Wallet = .mock(),
        perpetualService: PerpetualServiceable = PerpetualService.mock(),
        activityService: ActivityService = .mock()
    ) -> PerpetualsSceneViewModel {
        PerpetualsSceneViewModel(
            wallet: wallet,
            perpetualService: perpetualService,
            activityService: activityService
        )
    }
}
