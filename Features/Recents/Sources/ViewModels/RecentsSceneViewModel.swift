// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PrimitivesComponents
import Store
import Components

@Observable
@MainActor
public final class RecentsSceneViewModel {
    var request: RecentActivityRequest
    public let onSelect: (Asset) -> Void

    var recentAssets: [RecentAsset] = []
    var searchQuery: String = ""

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
        RecentAssetsSection.from(filteredAssets)
    }

    var showEmpty: Bool {
        !searchQuery.isEmpty && filteredAssets.isEmpty
    }

    var emptyModel: any EmptyContentViewable {
        EmptyContentTypeViewModel(type: .search(type: .assets))
    }

    private var filteredAssets: [RecentAsset] {
        guard !searchQuery.isEmpty else { return recentAssets }
        return recentAssets.filter {
            $0.asset.name.localizedCaseInsensitiveContains(searchQuery) ||
            $0.asset.symbol.localizedCaseInsensitiveContains(searchQuery)
        }
    }
}
