// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives
import WalletsServiceTestKit

extension SelectAssetViewModel {
    static func mock(
        db: DB,
        selectType: SelectAssetType
    ) -> SelectAssetViewModel {
        SelectAssetViewModel(
            wallet: .mock(accounts: [AssetBasic].mock().map { Account.mock(chain: $0.asset.chain) }),
            selectType: selectType,
            assetsService: .mock(),
            walletsService: .mock(
                assetsService: .mock(
                    assetStore: .mock(db: db),
                    balanceStore: .mock(db: db)
                )
            ),
            priceAlertService: .mock()
        )
    }
}
