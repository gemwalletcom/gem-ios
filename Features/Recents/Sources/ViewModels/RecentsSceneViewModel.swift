// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PrimitivesComponents
import Store

@Observable
@MainActor
public final class RecentsSceneViewModel {
    var request: RecentActivityRequest
    public let onSelect: (Asset) -> Void

    var recentAssets: [RecentAsset] = []

    public init(
        walletId: String,
        types: [RecentActivityType],
        filters: [AssetsRequestFilter] = [],
        onSelect: @escaping (Asset) -> Void
    ) {
        self.request = RecentActivityRequest(
            walletId: walletId,
            limit: .max,
            types: types,
            filters: filters
        )
        self.onSelect = onSelect
    }

    var sections: [RecentAssetsSection] {
        RecentAssetsSection.from(recentAssets)
    }
}
