// Copyright (c). Gem Wallet. All rights reserved.

import Perpetuals
import Primitives
import PrimitivesTestKit
import PerpetualService
import PerpetualServiceTestKit

public extension PerpetualPortfolioSceneViewModel {
    @MainActor
    static func mock(
        wallet: Wallet = .mock(),
        perpetualService: PerpetualServiceable = PerpetualService.mock()
    ) -> PerpetualPortfolioSceneViewModel {
        PerpetualPortfolioSceneViewModel(
            wallet: wallet,
            perpetualService: perpetualService
        )
    }
}
