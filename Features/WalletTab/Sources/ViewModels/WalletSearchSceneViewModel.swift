// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Store
import PrimitivesComponents
import AssetsService
import Components
import Preferences
import Style
import Localization
import ActivityService

@Observable
@MainActor
public final class WalletSearchSceneViewModel: Sendable {
    private let searchService: AssetSearchService
    private let activityService: ActivityService
    private let preferences: Preferences

    private let wallet: Wallet
    private let onDismissSearch: VoidAction
    private let onAddToken: VoidAction

    private var state: StateViewType<[AssetBasic]> = .noData

    var assets: [AssetData] = []
    var recentActivities: [AssetData] = []
    var searchModel: AssetSearchViewModel
    var request: AssetsRequest
    var recentActivityRequest: RecentActivityRequest

    var isSearching: Bool = false
    var isSearchPresented: Bool = false
    var dismissSearch: Bool = false

    public let onSelectAssetAction: AssetAction

    public init(
        wallet: Wallet,
        searchService: AssetSearchService,
        activityService: ActivityService,
        preferences: Preferences = .standard,
        onDismissSearch: VoidAction,
        onSelectAssetAction: AssetAction
        onAddToken: VoidAction
    ) {
        self.wallet = wallet
        self.searchService = searchService
        self.activityService = activityService
        self.preferences = preferences
        self.onDismissSearch = onDismissSearch
        self.onSelectAssetAction = onSelectAssetAction
        self.onAddToken = onAddToken
        self.searchModel = AssetSearchViewModel(selectType: .manage)
        self.request = AssetsRequest(
            walletId: wallet.id,
            filters: []
        )
        self.recentActivityRequest = RecentActivityRequest(
            walletId: wallet.id,
            types: RecentActivityType.allCases,
            limit: 10
        )
    }

    var sections: AssetsSections {
        AssetsSections.from(assets)
    }

    var pinnedImage: Image { Images.System.pin }
    var pinnedTitle: String { Localized.Common.pinned }

    var assetsTitle: String { Localized.Assets.title }

    var showTags: Bool {
        searchModel.searchableQuery.isEmpty
    }

    var showRecentSearches: Bool {
        searchModel.searchableQuery.isEmpty && recentActivities.isNotEmpty
    }

    var recentSearchesTitle: String { Localized.RecentActivity.title }

    var showLoading: Bool {
        state.isLoading && showEmpty
    }

    var showEmpty: Bool {
        !showAssetsSection && !showPinnedSection
    }

    var showPinnedSection: Bool {
        sections.pinned.isNotEmpty
    }

    var showAssetsSection: Bool {
        sections.assets.isNotEmpty
    }

    var currencyCode: String {
        preferences.currency
    }

    var showAddToken: Bool {
        wallet.hasTokenSupport
    }
}

// MARK: - Actions

extension WalletSearchSceneViewModel {
    func onAppear() {
        dismissSearch = false
        isSearchPresented = true
    }

    func onSearch(query: String) async {
        let query = query.trim()
        guard !query.isEmpty else { return }
        await searchAssets(
            query: query,
            priorityAssetsQuery: searchModel.priorityAssetsQuery,
            tag: nil
        )
    }

    func onSelectTag(tag: AssetTagSelection) {
        searchModel.tagsViewModel.selectedTag = tag
        searchModel.focus = .tags
        updateRequest()
        Task {
            await searchAssets(
                query: .empty,
                priorityAssetsQuery: searchModel.priorityAssetsQuery,
                tag: searchModel.tagsViewModel.selectedTag.tag
            )
        }
    }

    func onChangeSearchQuery(_: String, _: String) {
        updateRequest()
    }

    func onChangeFocus(_: Bool, isSearching: Bool) {
        if isSearching {
            searchModel.focus = .search
            searchModel.tagsViewModel.selectedTag = AssetTagSelection.all
            updateRequest()
        }
    }

    func onChangeSearchPresented(_: Bool, isPresented: Bool) {
        guard !isPresented else { return }
        dismissSearch = true
        onDismissSearch?()
    }

    func onSelectAsset(_ asset: Asset) {
        onSelectAssetAction?(asset)
        updateRecent(asset)
    func onSelectAddCustomToken() {
        onAddToken?()
    }
}

// MARK: - Private

extension WalletSearchSceneViewModel {
    private func updateRecent(_ asset: Asset) {
        do {
            try activityService.updateRecent(type: .search, assetId: asset.id, walletId: wallet.walletId)
        } catch {
            debugLog("UpdateRecent error: \(error)")
        }
    }

    private func updateRequest() {
        if searchModel.searchableQuery.isNotEmpty && searchModel.focus == .tags {
            searchModel.focus = .search
            searchModel.tagsViewModel.selectedTag = AssetTagSelection.all
        }
        request.searchBy = searchModel.priorityAssetsQuery.or(.empty)
        state = .loading
    }

    private func searchAssets(
        query: String,
        priorityAssetsQuery: String?,
        tag: AssetTag?
    ) async {
        do {
            let assets = try await searchService.searchAssets(
                wallet: wallet,
                query: query,
                priorityAssetsQuery: priorityAssetsQuery,
                tag: tag
            )
            state = .data(assets)
        } catch {
            if !error.isCancelled {
                state = .error(error)
            }
        }
    }
}
