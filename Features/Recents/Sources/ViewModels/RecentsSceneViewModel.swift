// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PrimitivesComponents
import Store
import Components
import Localization
import ActivityService

@Observable
@MainActor
public final class RecentsSceneViewModel {
    private let activityService: ActivityService
    private let walletId: WalletId

    public let query: ObservableQuery<RecentActivityRequest>
    public let onSelect: (Asset) -> Void

    var searchQuery: String = ""

    public var recentAssets: [RecentAsset] { query.value }

    public init(
        walletId: WalletId,
        types: [RecentActivityType],
        filters: [AssetsRequestFilter] = [],
        activityService: ActivityService,
        onSelect: @escaping (Asset) -> Void
    ) {
        self.walletId = walletId
        self.activityService = activityService
        self.query = ObservableQuery(RecentActivityRequest(walletId: walletId, limit: .max, types: types, filters: filters), initialValue: [])
        self.onSelect = onSelect
    }

    var title: String { Localized.RecentActivity.title }
    var clearTitle: String { Localized.Filter.clear }

    var showEmpty: Bool { recentAssets.isEmpty || (!searchQuery.isEmpty && filteredAssets.isEmpty) }
    var showClear: Bool { recentAssets.isNotEmpty }

    var sections: [ListSection<RecentAsset>] {
        DateSectionBuilder(items: filteredAssets, dateKeyPath: \.createdAt).build()
    }
    var emptyModel: any EmptyContentViewable {
        if recentAssets.isEmpty {
            return EmptyContentTypeViewModel(type: .recents)
        }
        return EmptyContentTypeViewModel(type: .search(type: .assets))
    }

    private var filteredAssets: [RecentAsset] {
        guard !searchQuery.isEmpty else { return recentAssets }
        return recentAssets.filter {
            $0.asset.name.localizedCaseInsensitiveContains(searchQuery) ||
            $0.asset.symbol.localizedCaseInsensitiveContains(searchQuery)
        }
    }
}

// MARK: - Actions

extension RecentsSceneViewModel {
    func onSelectClear() {
        do {
            try activityService.clearRecent(walletId: walletId, types: RecentActivityType.allCases)
        } catch {
            debugLog("RecentsSceneViewModel clear error: \(error)")
        }
    }
}
