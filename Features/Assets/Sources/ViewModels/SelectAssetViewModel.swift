// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store
import Components
import Localization
import PrimitivesComponents
import AssetsService
import WalletsService
import Preferences
import PriceAlertService
import ActivityService

@Observable
@MainActor
public final class SelectAssetViewModel {
    let preferences: Preferences
    let selectType: SelectAssetType
    let searchService: AssetSearchService
    let walletsService: WalletsService
    let priceAlertService: PriceAlertService
    let activityService: ActivityService

    public let wallet: Wallet

    var assets: [AssetData] = []
    var recentActivities: [Asset] = []
    var state: StateViewType<[AssetBasic]> = .noData
    var searchModel: AssetSearchViewModel
    var request: AssetsRequest
    var recentActivityRequest: RecentActivityRequest

    var isSearching: Bool = false
    var isDismissSearch: Bool = false

    var isPresentingCopyToast: Bool = false
    var copyTypeViewModel: CopyTypeViewModel?
    public var isPresentingAddToken: Bool = false

    public var filterModel: AssetsFilterViewModel
    public var onSelectAssetAction: AssetAction

    public init(
        preferences: Preferences = Preferences.standard,
        wallet: Wallet,
        selectType: SelectAssetType,
        searchService: AssetSearchService,
        walletsService: WalletsService,
        priceAlertService: PriceAlertService,
        activityService: ActivityService,
        selectAssetAction: AssetAction = .none
    ) {
        self.preferences = preferences
        self.wallet = wallet
        self.selectType = selectType
        self.searchService = searchService
        self.walletsService = walletsService
        self.priceAlertService = priceAlertService
        self.activityService = activityService
        self.onSelectAssetAction = selectAssetAction

        let filter = AssetsFilterViewModel(
            type: selectType,
            model: ChainsFilterViewModel(
                chains: wallet.chains
            )
        )
        self.filterModel = filter
        self.searchModel = AssetSearchViewModel(selectType: selectType)

        self.request = AssetsRequest(
            walletId: wallet.id,
            filters: filter.filters
        )
        self.recentActivityRequest = RecentActivityRequest(
            walletId: wallet.id,
            limit: 10
        )
    }

    var title: String {
        switch selectType {
        case .send: Localized.Wallet.send
        case .receive(let type):
            switch type {
            case .asset: Localized.Wallet.receive
            case .collection: Localized.Wallet.receiveCollection
            }
        case .buy: Localized.Wallet.buy
        case .swap(let type):
            switch type {
            case .pay: Localized.Swap.youPay
            case .receive: Localized.Swap.youReceive
            }
        case .manage: Localized.Wallet.manageTokenList
        case .priceAlert: Localized.Assets.selectAsset
        case .deposit: Localized.Wallet.deposit
        case .withdraw: Localized.Wallet.withdraw
        }
    }

    var sections: AssetsSections {
        AssetsSections.from(assets)
    }

    var enablePopularSection: Bool {
        [.buy, .priceAlert].contains(selectType)
    }

    public var showAddToken: Bool {
        selectType == .manage && wallet.hasTokenSupport && !filterModel.chainsFilter.isEmpty
    }

    public var showFilter: Bool {
        switch selectType {
        case .receive(let type):
            switch type {
            case .asset:
                wallet.isMultiCoins && !filterModel.chainsFilter.isEmpty
            case .collection: false
            }
        case .buy, .manage, .priceAlert, .send, .swap, .deposit, .withdraw:
            wallet.isMultiCoins && !filterModel.chainsFilter.isEmpty
        }
    }

    var isNetworkSearchEnabled: Bool {
        switch selectType {
        case .manage, .receive, .buy, .priceAlert: return true
        case let .swap(type):
            switch type {
            case .pay: return false
            case .receive: return true
            }
        case .send, .deposit, .withdraw: return false
        }
    }

    var showTags: Bool {
        searchModel.searchableQuery.isEmpty
    }

    var showRecentActivities: Bool {
        switch selectType {
        case .send, .receive, .buy: searchModel.searchableQuery.isEmpty && recentActivities.isNotEmpty
        case .swap, .manage, .priceAlert, .deposit, .withdraw: false
        }
    }

    var recentActivityTitle: String {
        Localized.RecentActivity.title
    }

    var activityModels: [AssetViewModel] {
        recentActivities.map { AssetViewModel(asset: $0) }
    }

    var currencyCode: String {
        preferences.currency
    }

    func assetAddress(for asset: Asset) -> AssetAddress {
        let address = (try? wallet.account(for: asset.chain).address) ?? ""
        return AssetAddress(asset: asset, address: address)
    }
}

// MARK: - Business Logic

extension SelectAssetViewModel {
    func selectAsset(asset: Asset) {
        switch selectType {
        case .priceAlert:
            Task {
                await setPriceAlert(assetId: asset.id, enabled: true)
            }
            case .manage, .send, .receive, .buy, .swap, .deposit, .withdraw: break
        }
        onSelectAssetAction?(asset)
    }

    func search(query: String) async {
        let query = query.trim()
        if query.isEmpty {
            return
        }
        await searchAssets(
            query: query,
            priorityAssetsQuery: searchModel.priorityAssetsQuery,
            tag: nil
        )
    }

    func handleAction(assetId: AssetId, enabled: Bool) async {
        switch selectType {
        case .manage:
            await walletsService.enableAssets(walletId: wallet.walletId, assetIds: [assetId], enabled: enabled)
        case .send, .receive, .buy, .swap, .priceAlert, .deposit, .withdraw: break
        }
    }

    func setSelected(tag: AssetTagSelection) {
        isDismissSearch.toggle()
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

    func updateRequest() {
        request.searchBy = searchModel.priorityAssetsQuery.or(.empty)
        state = isNetworkSearchEnabled ? .loading : .noData
    }

    func onChangeFocus(_: Bool, isSearchable: Bool) {
        if isSearchable {
            searchModel.focus = .search
            searchModel.tagsViewModel.selectedTag = .all
            updateRequest()
        }
    }

    func onChangeFilterModel(_: AssetsFilterViewModel, model: AssetsFilterViewModel) {
        request.filters = model.filters
    }
}

// MARK: - Actions

extension SelectAssetViewModel {
    func onAssetAction(action: ListAssetItemAction, assetData: AssetData) {
        let asset = assetData.asset
        switch action {
        case .switcher(let enabled):
            Task {
                await handleAction(assetId: asset.id, enabled: enabled)
            }
        case .copy:
            let address = assetData.account.address
            copyTypeViewModel = CopyTypeViewModel(
                type: .address(asset, address: address),
                copyValue: address
            )
            isPresentingCopyToast = true
            Task {
                await handleAction(assetId: asset.id, enabled: true)
            }
        }
    }
    
    func onSelectAddCustomToken() {
        isPresentingAddToken.toggle()
    }
}

// MARK: - Private

extension SelectAssetViewModel {
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
            await handle(error: error)
        }
    }

    private func setPriceAlert(assetId: AssetId, enabled: Bool) async {
        do {
            let currency = Preferences.standard.currency
            if enabled {
                try await priceAlertService.add(priceAlert: .default(for: assetId, currency: currency))
            } else {
                try await priceAlertService.delete(priceAlerts: [.default(for: assetId, currency: currency)])
            }
        } catch {
            await handle(error: error)
        }
    }

    private func handle(error: any Error) async {
        await MainActor.run { [self] in
            if !error.isCancelled {
                self.state = .error(error)
                debugLog("SelectAssetScene scene error: \(error)")
            }
        }
    }
}

// MARK: - Models extensions

extension SelectAssetType {
    var listType: AssetListType {
        switch self {
        case .send,
                .buy,
                .swap,
                .deposit,
                .withdraw: .view
        case .receive: .copy
        case .manage: .manage
        case .priceAlert: .price
        }
    }
}
