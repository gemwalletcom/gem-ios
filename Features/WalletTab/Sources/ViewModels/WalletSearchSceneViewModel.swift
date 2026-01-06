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
    private let searchService: AssetSearchService
    private let activityService: ActivityService
    private let walletsService: WalletsService
    private let preferences: Preferences

    private let wallet: Wallet
    private let onDismissSearch: VoidAction
    private let onAddToken: VoidAction

    private var state: StateViewType<[AssetBasic]> = .noData

    var assets: [AssetData] = []
    var recentActivities: [Asset] = []
    var positions: [PerpetualPositionData] = []
    var searchModel: AssetSearchViewModel

    var request: AssetsRequest
    var positionsRequest: PerpetualPositionsRequest
    var recentActivityRequest: RecentActivityRequest

    var isPresentingToastMessage: ToastMessage? = nil
    var isSearching: Bool = false
    var isSearchPresented: Bool = false
    var dismissSearch: Bool = false

    public let onSelectAssetAction: AssetAction

    public init(
        wallet: Wallet,
        searchService: AssetSearchService,
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
        self.request = AssetsRequest(
            walletId: wallet.id,
            filters: []
        )
        self.recentActivityRequest = RecentActivityRequest(
            walletId: wallet.id,
            limit: 10,
            types: RecentActivityType.allCases.filter { $0 != .perpetual }
        )
        self.positionsRequest = PerpetualPositionsRequest(walletId: wallet.walletId.id)
    }

    var pinnedImage: Image { Images.System.pin }
    var pinnedTitle: String { Localized.Common.pinned }
    var perpetualsTitle: String { Localized.Perpetuals.title }
    var assetsTitle: String { Localized.Assets.title }

    var sections: AssetsSections { AssetsSections.from(assets) }
    var activityModels: [AssetViewModel] { recentActivities.map { AssetViewModel(asset: $0) } }
    var currencyCode: String { preferences.currency }

    var showTags: Bool { searchModel.searchableQuery.isEmpty }
    var showRecent: Bool { searchModel.searchableQuery.isEmpty && recentActivities.isNotEmpty }
    var showPerpetuals: Bool { positions.isNotEmpty && preferences.isPerpetualEnabled && wallet.isMultiCoins }
    var showLoading: Bool { state.isLoading && showEmpty }
    var showEmpty: Bool { !showRecent && !showPerpetuals && !showPinned && !showAssets }
    var showPinned: Bool { sections.pinned.isNotEmpty }
    var showAssets: Bool { sections.assets.isNotEmpty }
    var showAddToken: Bool { wallet.hasTokenSupport }
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
        }
        request.searchBy = searchModel.priorityAssetsQuery.or(.empty)
        positionsRequest.searchQuery = searchModel.searchableQuery
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
