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
class SelectAssetViewModel {
    let preferences: Preferences
    let wallet: Wallet
    let selectType: SelectAssetType
    let assetsService: AssetsService
    let walletsService: WalletsService
    let priceAlertService: PriceAlertService

    var state: StateViewType<[AssetBasic]> = .noData
    var filterModel: AssetsFilterViewModel
    var request: AssetsRequest

    var selectAssetAction: AssetAction

    init(
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
        self.selectAssetAction = selectAssetAction

        let filter = AssetsFilterViewModel(
            type: selectType,
            model: ChainsFilterViewModel(
                chains: wallet.chains
            )
        )
        self.filterModel = filter
        self.request = AssetsRequest(
            walletID: wallet.id,
            filters: filter.defaultFilters
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
    
    var enablePopularSection: Bool {
        [.buy, .priceAlert].contains(selectType)
    }

    var showAddToken: Bool {
        selectType == .manage && wallet.hasTokenSupport && !filterModel.chainsFilter.isEmpty
    }

    var showFilter: Bool {
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
        guard wallet.hasTokenSupport else { return false }
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

    var currencyCode: String {
        preferences.currency
    }
}

// MARK: - Business Logic

extension SelectAssetViewModel {
    func selectAsset(asset: Asset) {
        selectAssetAction?(asset)
    }

    func update(filterRequest: AssetsRequestFilter) {
        request.filters.removeAll { existingFilter in
            switch (filterRequest, existingFilter) {
            case (.chains, .chains):
                return true
            default:
                return false
            }
        }
        request.filters.append(filterRequest)
    }

    func search(query: String) async {
        let query = query.trim()
        if query.isEmpty {
            return
        }
        await searchAssets(query: query)
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
}

// MARK: - Private

extension SelectAssetViewModel {
    private func chains(for type: WalletType) -> [Chain] {
        switch wallet.type {
        case .single, .view, .privateKey: [wallet.accounts.first?.chain].compactMap { $0 }
        case .multicoin: []
        }
    }

    private func searchAssets(query: String) async {
        await MainActor.run { [self] in
            self.state = .loading

            if query.isEmpty {
                self.state = .noData
                return
            }
        }

        let chains: [Chain] = chains(for: wallet.type)

        do {
            let assets = try await assetsService.searchAssets(query: query, chains: chains)
            try assetsService.addAssets(assets: assets)
            try assetsService.assetStore.addAssetsSearch(query: query, assets: assets)
            
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
            if enabled {
                try await priceAlertService.add(priceAlert: .default(for: assetId.identifier))
            } else {
                try await priceAlertService.delete(priceAlerts: [.default(for: assetId.identifier)])
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
        case .manage:.manage
        case .priceAlert: .price
        }
    }
}
