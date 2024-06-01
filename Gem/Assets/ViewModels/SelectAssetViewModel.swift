import Foundation
import Keystore
import Primitives
import Store
import Settings

class SelectAssetViewModel: ObservableObject {
    
    let wallet: Wallet
    let keystore: any Keystore
    let selectType: SelectAssetType
    let assetsService: AssetsService
    let walletService: WalletService
    
    private let searchAssetsTaskDebounceTimeout = Duration.milliseconds(250)
    private var searchAssetsTask: Task<[AssetFull], Error>?
    
    @Published var isLoading: Bool = false
    
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
    
    var filterChains: [String] {
        switch wallet.type {
        case .multicoin:
            return []
        case .view, .single:
            guard let chain = wallet.accounts.first?.chain else {
                return []
            }
            return [chain.rawValue]
        }
    }
    
    var assetRequest: AssetsRequest {
        switch selectType {
        case .send:
            return AssetsRequest(walletID: wallet.id, chains: filterChains, filters: [.hasBalance])
        case .receive:
            return AssetsRequest(walletID: wallet.id, chains: filterChains, filters: [.includeNewAssets])
        case .buy:
            return AssetsRequest(walletID: wallet.id, chains: filterChains, filters: [.buyable, .includeNewAssets])
        case .swap:
            return AssetsRequest(walletID: wallet.id, chains: filterChains, filters: [.swappable])
        case .stake:
            return AssetsRequest(walletID: wallet.id, chains: filterChains, filters: [.stakeable])
        case .manage:
            return AssetsRequest(walletID: wallet.id, chains: filterChains, filters: [.includeNewAssets])
        case .hidden:
            return AssetsRequest(walletID: wallet.id, chains: filterChains, filters: [.hidden])
        }
    }
    
    var showAssetsInfo: Bool {
        selectType == .manage
    }
    
    var showAddToken: Bool {
        selectType == .manage && wallet.accounts.map { $0.chain }.asSet().intersection(AssetConfiguration.supportedChainsWithTokens).count > 0
    }
    
    var assetsInfoRequest: AssetsInfoRequest {
        return AssetsInfoRequest(walletId: wallet.id)
    }
    
    func enableAsset(assetId: AssetId, enabled: Bool) {
        walletService.enableAssetId(wallet: wallet, assets: [assetId], enabled: enabled)
    }
    
    func searchQuery(query: String) async {
        let query = query.trim()
        switch selectType {
        case .manage, .receive, .buy:
            await searchAssets(query: query)
        case .send, .stake, .swap, .hidden:
            break
        }
    }
    
    private func chains(for type: WalletType) -> [Chain] {
        switch wallet.type {
        case .single, .view: [wallet.accounts.first?.chain].compactMap { $0 }
        case .multicoin: []
        }
    }
    
    private func searchAssets(query: String) async {
        let chains: [Chain] = chains(for: wallet.type)
        
        searchAssetsTask?.cancel()
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        if query.isEmpty {
            DispatchQueue.main.async {
                self.isLoading = false
            }
            return
        }
        Task {
            do {
                let task = Task.detached {
                    try await Task.sleep(for: self.searchAssetsTaskDebounceTimeout)
                    return try await self.assetsService.searchAssets(query: query, chains: chains)
                }
                searchAssetsTask = task
                let assets = try await task.value
                try assetsService.addAssets(assets: assets)
                try assetsService.addBalancesIfMissing(walletId: wallet.id, assetIds: assets.map { $0.asset.id })
                
                NSLog("searchAssets assets count: \(assets.count)")
                
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            } catch {
                if error.isCancelled {
                    return
                }
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                NSLog("searchAssets assets error: \(error)")
            }
        }
    }
}

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
