// Copyright (c). Gem Wallet. All rights reserved.

import Perpetuals
import Primitives
import PrimitivesTestKit
import PerpetualService
import PerpetualServiceTestKit
import ActivityService
import ActivityServiceTestKit

public extension PerpetualsSceneViewModel {
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
