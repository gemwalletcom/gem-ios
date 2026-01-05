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

    var assets: [Asset] = []

    public var models: [AssetViewModel] {
        assets.map { AssetViewModel(asset: $0) }
    }

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
}
