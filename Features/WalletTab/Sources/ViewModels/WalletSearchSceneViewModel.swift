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

@Observable
@MainActor
public final class WalletSearchSceneViewModel: Sendable {
    private let searchService: AssetSearchService
    private let preferences: Preferences

    private let wallet: Wallet

    private var state: StateViewType<[AssetBasic]> = .noData

    var assets: [AssetData] = []
    var searchModel: AssetSearchViewModel
    var request: AssetsRequest

    var isSearching: Bool = false
    var dismissSearch: Bool = false

    public init(
        wallet: Wallet,
        searchService: AssetSearchService,
        preferences: Preferences = .standard
    ) {
        self.wallet = wallet
        self.searchService = searchService
        self.preferences = preferences
        self.searchModel = AssetSearchViewModel(selectType: .manage)
        self.request = AssetsRequest(
            walletId: wallet.id,
            filters: []
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
    }
}

// MARK: - Private

extension WalletSearchSceneViewModel {
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
