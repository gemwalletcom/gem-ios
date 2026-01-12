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

@Observable
@MainActor
public final class WalletSearchSceneViewModel: Sendable {
    private let searchService: WalletSearchService
    let activityService: ActivityService
    private let walletsService: WalletsService
    private let preferences: Preferences

    let wallet: Wallet
    private let onDismissSearch: VoidAction
    private let onAddToken: VoidAction

    private var state: StateViewType<Bool> = .noData

    var searchModel: AssetSearchViewModel
    var searchResult: WalletSearchResult = .empty
    var recents: [RecentAsset] = []

    var searchRequest: WalletSearchRequest
    var recentsRequest: RecentActivityRequest

    var isPresentingToastMessage: ToastMessage? = nil
    var isSearching: Bool = false
    var isSearchPresented: Bool = false
    var dismissSearch: Bool = false
    var isPresentingRecents: Bool = false

    public let onSelectAssetAction: AssetAction

    public init(
        wallet: Wallet,
        searchService: WalletSearchService,
        activityService: ActivityService,
        walletsService: WalletsService,
        preferences: Preferences = .standard,
        onDismissSearch: VoidAction,
        onSelectAssetAction: AssetAction,
        onAddToken: VoidAction
    ) {
        self.wallet = wallet
        self.searchService = searchService
        self.activityService = activityService
        self.walletsService = walletsService
        self.preferences = preferences
        self.onDismissSearch = onDismissSearch
        self.onSelectAssetAction = onSelectAssetAction
        self.onAddToken = onAddToken
        self.searchModel = AssetSearchViewModel(selectType: .manage)
        self.searchRequest = WalletSearchRequest(walletId: wallet.walletId)
        self.recentsRequest = RecentActivityRequest(
            walletId: wallet.walletId,
            limit: 10,
            types: RecentActivityType.allCases.filter { $0 != .perpetual }
        )
    }

    var pinnedImage: Image { Images.System.pin }
    var pinnedTitle: String { Localized.Common.pinned }
    var perpetualsTitle: String { Localized.Perpetuals.title }
    var assetsTitle: String { Localized.Assets.title }

    var sections: WalletSearchSections { .from(searchResult) }
    var recentModels: [AssetViewModel] { recents.map { AssetViewModel(asset: $0.asset) } }
    var currencyCode: String { preferences.currency }

    var showTags: Bool { searchModel.searchableQuery.isEmpty }
    var showRecents: Bool { searchModel.searchableQuery.isEmpty && recents.isNotEmpty }
    var showPerpetuals: Bool { sections.perpetuals.isNotEmpty && preferences.isPerpetualEnabled }
    var showLoading: Bool { state.isLoading && showEmpty }
    var showEmpty: Bool { !showRecents && !showPinned && !showAssets && !showPerpetuals }
    var showPinned: Bool { sections.pinned.isNotEmpty }
    var showAssets: Bool { sections.assets.isNotEmpty }
    var showAddToken: Bool { wallet.hasTokenSupport }

    func contextMenuItems(for assetData: AssetData) -> [ContextMenuItemType] {
        [
            .copy(
                title: Localized.Wallet.copyAddress,
                value: assetData.account.address,
                onCopy: { [weak self] in
                    self?.onSelectCopyAddress(CopyTypeViewModel(type: .address(assetData.asset, address: $0), copyValue: $0).message)
                }
            ),
            .pin(
                isPinned: assetData.metadata.isPinned,
                onPin: { [weak self] in
                    self?.onSelectPinAsset(assetData, value: !assetData.metadata.isPinned)
                }
            ),
            !assetData.metadata.isBalanceEnabled ? .custom(
                title: Localized.Asset.addToWallet,
                systemImage: SystemImage.plusCircle,
                action: { [weak self] in
                    self?.onSelectAddToWallet(assetData.asset)
                }
            ) : nil
        ].compactMap { $0 }
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

    func onSelectCopyAddress(_ message: String) {
        isPresentingToastMessage = .copy(message)
    }

    func onChangeSearchQuery(_: String, _: String) {
        updateRequest()
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
    private func updateRecent(_ asset: Asset) {
        do {
            try activityService.updateRecent(
                data: RecentActivityData(type: .search, assetId: asset.id, toAssetId: nil),
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
