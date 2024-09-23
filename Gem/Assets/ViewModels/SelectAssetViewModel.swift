import Foundation
import Keystore
import Primitives
import Store
import Components

@Observable
class SelectAssetViewModel {
    let wallet: Wallet
    let keystore: any Keystore
    let selectType: SelectAssetType
    let assetsService: AssetsService
    let walletsService: WalletsService

    var state: StateViewType<[AssetFull]> = .noData
    var filterModel: AssetsFilterViewModel

    var selectAssetAction: AssetAction?

    init(
        wallet: Wallet,
        keystore: any Keystore,
        selectType: SelectAssetType,
        assetsService: AssetsService,
        walletsService: WalletsService,
        selectAssetAction: AssetAction? = .none
    ) {
        self.wallet = wallet
        self.keystore = keystore
        self.selectType = selectType
        self.assetsService = assetsService
        self.walletsService = walletsService
        self.selectAssetAction = selectAssetAction

        self.filterModel = AssetsFilterViewModel(wallet: wallet, type: selectType)
    }

    var title: String {
        switch selectType {
        case .send: Localized.Wallet.send
        case .receive: Localized.Wallet.receive
        case .buy: Localized.Wallet.buy
        case .swap: Localized.Wallet.swap
        case .stake: Localized.Wallet.stake
        case .manage: Localized.Wallet.manageTokenList
        case .priceAlert: Localized.Assets.selectAsset
        }
    }

    var showAddToken: Bool {
        selectType == .manage && !filterModel.allChains.isEmpty
    }

    func selectAsset(asset: Asset) {
        selectAssetAction?(asset)
    }
}

// MARK: - Business Logic

extension SelectAssetViewModel {
    func search(query: String) async {
        let query = query.trim()
        switch selectType {
        case .manage, .receive, .buy, .priceAlert:
            await searchAssets(query: query)
        case .send, .stake, .swap:
            break
        }
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
