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
import WalletsService
import PerpetualService
import Recents

@Observable
@MainActor
public final class WalletSearchSceneViewModel: Sendable {

    private let searchService: WalletSearchService
    private let activityService: ActivityService
    private let walletsService: WalletsService
    private let perpetualService: PerpetualService
    private let preferences: ObservablePreferences

    private let wallet: Wallet
    private let onDismissSearch: VoidAction
    private let onAddToken: VoidAction

    private var state: StateViewType<Bool> = .noData

    var searchModel: WalletSearchModel
    var searchResult: WalletSearchResult = .empty
    var recents: [RecentAsset] = []

    var searchRequest: WalletSearchRequest
    var recentsRequest: RecentActivityRequest

    var isPresentingToastMessage: ToastMessage? = nil
    var isSearching: Bool = false
    var isSearchPresented: Bool = false
    var dismissSearch: Bool = false
    var isPresentingRecents: Bool = false

    let onSelectAssetAction: AssetAction

    public init(
        wallet: Wallet,
        searchService: WalletSearchService,
        activityService: ActivityService,
        walletsService: WalletsService,
        perpetualService: PerpetualService,
        preferences: ObservablePreferences = .default,
        onDismissSearch: VoidAction,
        onSelectAssetAction: AssetAction,
        onAddToken: VoidAction
    ) {
        self.wallet = wallet
        self.searchService = searchService
        self.activityService = activityService
        self.walletsService = walletsService
        self.perpetualService = perpetualService
        self.preferences = preferences
        self.onDismissSearch = onDismissSearch
        self.onSelectAssetAction = onSelectAssetAction
        self.onAddToken = onAddToken
        self.searchModel = WalletSearchModel(selectType: .manage)

        let isPerpetualEnabled = preferences.isPerpetualEnabled
        self.searchRequest = WalletSearchRequest(
            walletId: wallet.walletId,
            limit: WalletSearchModel.initialFetchLimit(isPerpetualEnabled: isPerpetualEnabled),
            types: WalletSearchModel.searchItemTypes(isPerpetualEnabled: isPerpetualEnabled)
        )
        self.recentsRequest = RecentActivityRequest(
            walletId: wallet.walletId,
            limit: 10,
            types: WalletSearchModel.recentActivityTypes(isPerpetualEnabled: isPerpetualEnabled)
        )
    }

    var isPerpetualEnabled: Bool { preferences.isPerpetualEnabled }

    var perpetualsTitle: String { Localized.Perpetuals.title }
    var assetsTitle: String { Localized.Assets.title }

    var sections: WalletSearchSections { .from(searchResult) }
    var recentModels: [AssetViewModel] { recents.map { AssetViewModel(asset: $0.asset) } }
    var currencyCode: String { preferences.preferences.currency }

    var showTags: Bool { searchModel.searchableQuery.isEmpty }
    var showRecents: Bool { searchModel.searchableQuery.isEmpty && recents.isNotEmpty }
    var showPerpetuals: Bool { sections.perpetuals.isNotEmpty && preferences.isPerpetualEnabled }
    var showLoading: Bool { state.isLoading && showEmpty }
    var showEmpty: Bool { !showRecents && !showPinned && !showAssets && !showPerpetuals }
    var showPinned: Bool { sections.pinnedAssets.isNotEmpty || showPinnedPerpetuals }
    var showPinnedPerpetuals: Bool { sections.pinnedPerpetuals.isNotEmpty && preferences.isPerpetualEnabled }
    var showAssets: Bool { sections.assets.isNotEmpty }
    var showAddToken: Bool { wallet.hasTokenSupport }

    var previewAssets: [AssetData] { Array(sections.assets.prefix(assetsPreviewLimit)) }
    var previewPerpetuals: [PerpetualData] { Array(sections.perpetuals.prefix(searchModel.perpetualsLimit)) }
    var hasMoreAssets: Bool { searchResult.assets.count > assetsPreviewLimit }
    var hasMorePerpetuals: Bool { searchResult.perpetuals.count > searchModel.perpetualsLimit }

    var recentsModel: RecentsSceneViewModel {
        RecentsSceneViewModel(
            walletId: wallet.walletId,
            types: recentsRequest.types,
            filters: recentsRequest.filters,
            activityService: activityService,
            onSelect: onSelectRecent
        )
    }

    var assetsResultsDestination: Scenes.AssetsResults {
        Scenes.AssetsResults(
            searchQuery: searchRequest.searchBy,
            tag: searchRequest.tag
        )
    }

    func contextMenuItems(for assetData: AssetData) -> [ContextMenuItemType] {
        AssetContextMenu.items(
            for: assetData,
            onCopy: { [weak self] in
                self?.onSelectCopyAddress(CopyTypeViewModel(type: .address(assetData.asset, address: $0), copyValue: $0).message)
            },
            onPin: { [weak self] in
                self?.onSelectPinAsset(assetData, value: !assetData.metadata.isPinned)
            },
            onAddToWallet: { [weak self] in
                self?.onSelectAddToWallet(assetData.asset)
            }
        )
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

        await search(query: query)
    }

    func onSelectTag(tag: AssetTagSelection) {
        searchModel.tagsViewModel.selectedTag = tag
        searchModel.focus = .tags
        searchRequest.tag = tag.tag?.rawValue
        updateRequest()
        Task {
            await search(query: .empty, tag: tag.tag)
        }
    }

    func onSelectAsset(_ asset: Asset) {
        onSelectAssetAction?(asset)
        updateRecent(asset)
    }

    func onSelectRecents() {
        isPresentingRecents = true
    }

    func onSelectRecent(asset: Asset) {
        onSelectAssetAction?(asset)
        isPresentingRecents = false
    }

    func onSelectAddCustomToken() {
        onAddToken?()
    }

    func onSelectAddToWallet(_ asset: Asset) {
        Task {
            await walletsService.enableAssets(walletId: wallet.walletId, assetIds: [asset.id], enabled: true)
            isPresentingToastMessage = .addedToWallet()
        }
    }

    func onSelectPinAsset(_ assetData: AssetData, value: Bool) {
        do {
            try walletsService.setPinned(value, walletId: wallet.walletId, assetId: assetData.asset.id)
            isPresentingToastMessage = .pin(assetData.asset.name, pinned: value)
        } catch {
            debugLog("WalletSearchSceneViewModel pin asset error: \(error)")
        }
    }

    func onSelectPinPerpetual(_ perpetualId: String, value: Bool) {
        do {
            try perpetualService.setPinned(value, perpetualId: perpetualId)
            if let name = searchResult.perpetuals.first(where: { $0.perpetual.id == perpetualId })?.perpetual.name {
                isPresentingToastMessage = .pin(name, pinned: value)
            }
        } catch {
            debugLog("WalletSearchSceneViewModel pin perpetual error: \(error)")
        }
    }

    func onSelectCopyAddress(_ message: String) {
        isPresentingToastMessage = .copy(message)
    }

    func onChangeSearchQuery(_: String, _: String) {
        updateRequest()
    }

    func onChangePerpetualsEnabled(_: Bool, _: Bool) {
        recentsRequest.types = WalletSearchModel.recentActivityTypes(isPerpetualEnabled: isPerpetualEnabled)
        searchRequest.types = WalletSearchModel.searchItemTypes(isPerpetualEnabled: isPerpetualEnabled)
        searchRequest.limit = searchModel.fetchLimit(tag: searchRequest.tag, isPerpetualEnabled: isPerpetualEnabled)
    }

    func onChangeFocus(_: Bool, isSearching: Bool) {
        if isSearching {
            searchModel.focus = .search
            searchModel.tagsViewModel.selectedTag = AssetTagSelection.all
            searchRequest.tag = nil
            updateRequest()
        }
    }

    func onChangeSearchPresented(_: Bool, isPresented: Bool) {
        guard !isPresented else { return }
        dismissSearch = true
        onDismissSearch?()
    }
}

// MARK: - Private

extension WalletSearchSceneViewModel {
    private var assetsPreviewLimit: Int {
        searchModel.assetsLimit(tag: searchRequest.tag, isPerpetualEnabled: preferences.isPerpetualEnabled)
    }

    private func updateRecent(_ asset: Asset) {
        do {
            try activityService.updateRecent(
                data: RecentActivityData(
                    type: asset.type == .perpetual ? .perpetual : .search,
                    assetId: asset.id,
                    toAssetId: nil
                ),
                walletId: wallet.walletId
            )
        } catch {
            debugLog("UpdateRecent error: \(error)")
        }
    }

    private func updateRequest() {
        if searchModel.searchableQuery.isNotEmpty && searchModel.focus == .tags {
            searchModel.focus = .search
            searchModel.tagsViewModel.selectedTag = AssetTagSelection.all
            searchRequest.tag = nil
        }
        searchRequest.searchBy = searchModel.searchableQuery
        searchRequest.limit = searchModel.fetchLimit(tag: searchRequest.tag, isPerpetualEnabled: preferences.isPerpetualEnabled)
        state = searchModel.searchableQuery.isNotEmpty || searchRequest.tag != nil ? .loading : .noData
    }

    private func search(query: String, tag: AssetTag? = nil) async {
        state = .loading
        do {
            try await searchService.search(wallet: wallet, query: query, tag: tag)
            state = .data(true)
        } catch {
            if !error.isCancelled {
                state = .error(error)
                debugLog("Search error: \(error)")
            }
        }
    }
}
