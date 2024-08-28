import Foundation
import Keystore
import Primitives
import Store
import Settings
import Components

@Observable
class SelectAssetViewModel {
    let wallet: Wallet
    let keystore: any Keystore
    let selectType: SelectAssetType
    let assetsService: AssetsService
    let walletService: WalletService

    var state: StateViewType<[AssetFull]> = .noData
    var filterModel: AssetsFilterViewModel

    init(
        wallet: Wallet,
        keystore: any Keystore,
        selectType: SelectAssetType,
        assetsService: AssetsService,
        walletService: WalletService
    ) {
        self.wallet = wallet
        self.keystore = keystore
        self.selectType = selectType
        self.assetsService = assetsService
        self.walletService = walletService

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
        case .hidden: Localized.Assets.hidden
        }
    }

    var assetsInfoRequest: AssetsInfoRequest {
        AssetsInfoRequest(walletId: wallet.walletId.id)
    }

    var showAssetsInfo: Bool {
        selectType == .manage
    }
    
    var showAddToken: Bool {
        selectType == .manage && wallet.accounts.map { $0.chain }.asSet().intersection(AssetConfiguration.supportedChainsWithTokens).count > 0
    }
}

// MARK: - Business Logic

extension SelectAssetViewModel {
    func search(query: String) async {
        let query = query.trim()
        switch selectType {
        case .manage, .receive, .buy:
            await searchAssets(query: query)
        case .send, .stake, .swap, .hidden:
            break
        }
    }

    func enableAsset(assetId: AssetId, enabled: Bool) {
        walletService.enableAssetId(walletId: wallet.walletId, assets: [assetId], enabled: enabled)
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
            .stake:
            return .view
        case .receive:
            return .copy
        case .manage,
            .hidden:
            return .manage
        }
    }
}
