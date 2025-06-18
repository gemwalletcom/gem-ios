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

@Observable
@MainActor
public final class SelectAssetViewModel {
    let preferences: Preferences
    let selectType: SelectAssetType
    let assetsService: AssetsService
    let walletsService: WalletsService
    let priceAlertService: PriceAlertService

    public let wallet: Wallet

    var assets: [AssetData] = []
    var state: StateViewType<[AssetBasic]> = .noData
    var searchModel: SelectAssetSearchViewModel
    var request: AssetsRequest

    var isSearching: Bool = false
    var isDismissSearch: Bool = false

    public var filterModel: AssetsFilterViewModel
    public var onSelectAssetAction: AssetAction

    public init(
        preferences: Preferences = Preferences.standard,
        wallet: Wallet,
        selectType: SelectAssetType,
        assetsService: AssetsService,
        walletsService: WalletsService,
        priceAlertService: PriceAlertService,
        selectAssetAction: AssetAction = .none
    ) {
        self.preferences = preferences
        self.wallet = wallet
        self.selectType = selectType
        self.assetsService = assetsService
        self.walletsService = walletsService
        self.priceAlertService = priceAlertService
        self.onSelectAssetAction = selectAssetAction

        let filter = AssetsFilterViewModel(
            type: selectType,
            model: ChainsFilterViewModel(
                chains: wallet.chains
            )
        )
        self.filterModel = filter
        self.searchModel = SelectAssetSearchViewModel(selectType: selectType)

        self.request = AssetsRequest(
            walletId: wallet.id,
            filters: filter.filters
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
        case .buy, .manage, .priceAlert, .send, .swap:
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
        case .send: return false
        }
    }

    var shouldShowTagFilter: Bool {
        searchModel.searchableQuery.isEmpty
    }

    var currencyCode: String {
        preferences.currency
    }
}

// MARK: - Business Logic

extension SelectAssetViewModel {
    func selectAsset(asset: Asset) {
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
        case .priceAlert:
            await setPriceAlert(assetId: assetId, enabled: enabled)
        case .send, .receive, .buy, .swap: break
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

// MARK: - Private

extension SelectAssetViewModel {
    private func searchChains(for type: WalletType) -> [Chain] {
        switch selectType {
        case .send, .receive, .manage, .buy, .swap:
            switch wallet.type {
            case .single, .view, .privateKey: [wallet.accounts.first?.chain].compactMap { $0 }
            case .multicoin: []
            }
        case .priceAlert: []
        }
    }

    private func searchAssets(
        query: String,
        priorityAssetsQuery: String?,
        tag: AssetTag?
    ) async {
        let chains: [Chain] = searchChains(for: wallet.type)

        do {
            let assets = try await assetsService.searchAssets(query: query, chains: chains, tags: [tag].compactMap { $0 })
            try assetsService.addAssets(assets: assets)
            if let priorityAssetsQuery {
                try assetsService.assetStore.addAssetsSearch(query: priorityAssetsQuery, assets: assets)
            }
            try assetsService.addBalancesIfMissing(walletId: wallet.walletId, assetIds: assets.map { $0.asset.id })

            await MainActor.run { [self] in
                self.state = .data(assets)
            }
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
                NSLog("SelectAssetScene scene error: \(error)")
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
                .swap: .view
        case .receive: .copy
        case .manage: .manage
        case .priceAlert: .price
        }
    }
}
