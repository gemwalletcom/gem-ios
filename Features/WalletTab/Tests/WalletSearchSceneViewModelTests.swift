// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import PrimitivesTestKit
import WalletTabTestKit
@testable import WalletTab

@MainActor
struct WalletSearchSceneViewModelTests {

    @Test
    func recentActivityTypes() {
        let model = WalletSearchSceneViewModel.mock()

        #expect(model.recentsRequest.types.contains(.perpetual) == false)
        #expect(model.recentsRequest.types.count == RecentActivityType.allCases.count - 1)
    }
}
