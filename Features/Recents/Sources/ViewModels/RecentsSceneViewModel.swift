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

    var request: RecentActivityRequest
    public let onSelect: (Asset) -> Void

    var recentAssets: [RecentAsset] = []
    var searchQuery: String = ""
    var isPresentingClearConfirmation: Bool?

    public init(
        walletId: WalletId,
        types: [RecentActivityType],
        filters: [AssetsRequestFilter] = [],
        activityService: ActivityService,
        onSelect: @escaping (Asset) -> Void
    ) {
        self.walletId = walletId
        self.activityService = activityService
        self.request = RecentActivityRequest(
            walletId: walletId,
            limit: .max,
            types: types,
            filters: filters
        )
        self.onSelect = onSelect
    }

    var title: String { Localized.RecentActivity.title }
    var clearTitle: String { Localized.Filter.clear }
    var clearConfirmationTitle: String { Localized.RecentActivity.clearConfirmation }

    var showEmpty: Bool { !searchQuery.isEmpty && filteredAssets.isEmpty }
    var showClear: Bool { recentAssets.isNotEmpty }

    var sections: [RecentAssetsSection] { RecentAssetsSection.from(filteredAssets) }
    var emptyModel: any EmptyContentViewable { EmptyContentTypeViewModel(type: .search(type: .assets)) }

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
        isPresentingClearConfirmation = true
    }

    func onSelectConfirmClear() {
        do {
            try activityService.clearRecent(walletId: walletId, types: RecentActivityType.allCases)
        } catch {
            debugLog("RecentsSceneViewModel clear error: \(error)")
        }
    }
}
