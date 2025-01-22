// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keystore
import Primitives
import Store
import Components
import Localization
import Settings
import PrimitivesComponents
import AssetsService

@Observable
class SelectAssetViewModel {
    let wallet: Wallet
    let keystore: any Keystore
    let selectType: SelectAssetType
    let assetsService: AssetsService
    let walletsService: WalletsService

    var state: StateViewType<[AssetBasic]> = .noData
    var filterModel: AssetsFilterViewModel
    var request: AssetsRequest

    var selectAssetAction: AssetAction

    init(
        wallet: Wallet,
        keystore: any Keystore,
        selectType: SelectAssetType,
        assetsService: AssetsService,
        walletsService: WalletsService,
        selectAssetAction: AssetAction = .none
    ) {
        self.wallet = wallet
        self.keystore = keystore
        self.selectType = selectType
        self.assetsService = assetsService
        self.walletsService = walletsService
        self.selectAssetAction = selectAssetAction

        let filter = AssetsFilterViewModel(
            type: selectType,
            model: ChainsFilterViewModel(
                chains: wallet.chains(type: .all)
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
        case .receive: Localized.Wallet.receive
        case .buy: Localized.Wallet.buy
        case .swap(let type):
            switch type {
            case .pay: Localized.Swap.youPay
            case .receive: Localized.Swap.youReceive
            }
        case .stake: Localized.Wallet.stake
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
        wallet.isMultiCoins && !filterModel.chainsFilter.isEmpty
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
        case .send, .stake: return false
        }
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
        await searchAssets(query: query)
    }

    func enableAsset(assetId: AssetId, enabled: Bool) {
        walletsService.enableAssetId(walletId: wallet.walletId, assets: [assetId], enabled: enabled)
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
            try assetsService.addBalancesIfMissing(walletId: wallet.walletId, assetIds: assets.map { $0.asset.id })

            await MainActor.run { [self] in
                self.state = .loaded(assets)
            }
        } catch {
            await MainActor.run { [self] in
                if !error.isCancelled {
                    self.state = .error(error)
                    NSLog("SelectAssetScene scene search assests error: \(error)")
                }
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
            .stake: .view
        case .receive: .copy
        case .manage:.manage
        case .priceAlert: .price
        }
    }
}

public extension Wallet {
    var hasTokenSupport: Bool {
        accounts.map { $0.chain }.asSet().intersection(AssetConfiguration.supportedChainsWithTokens).count > 0
    }
}
