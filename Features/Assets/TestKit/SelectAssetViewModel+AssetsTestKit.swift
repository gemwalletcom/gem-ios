// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PrimitivesTestKit
import Components
import WalletsServiceTestKit
import AssetsServiceTestKit
import PriceAlertServiceTestKit
import ActivityServiceTestKit

@testable import Assets
@testable import Store

extension SelectAssetViewModel {
    @MainActor
    public static func mock(
        wallet: Wallet = .mock(),
        selectType: SelectAssetType = .manage,
        assets: [AssetData] = [],
        state: StateViewType<[AssetBasic]> = .noData
    ) -> SelectAssetViewModel {
        let model = SelectAssetViewModel(
            wallet: wallet,
            selectType: selectType,
            searchService: .mock(),
            walletsService: .mock(),
            priceAlertService: .mock(),
            activityService: .mock()
        )
        model.assetsQuery.value = assets
        model.state = state
        return model
    }
}
