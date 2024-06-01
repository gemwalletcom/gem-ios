import Foundation
import Keystore
import Primitives
import Store
import Settings
import UIKit

struct WalletSceneViewModel {
    
    private let assetsService: AssetsService
    private let walletService: WalletService
    
    init(
        assetsService: AssetsService,
        walletService: WalletService
    ) {
        self.assetsService = assetsService
        self.walletService = walletService
    }
    
    func fetch(for wallet: Wallet, assetIds: [AssetId]) async throws {
        try await walletService.fetch(wallet: wallet, assetIds: assetIds)
    }
    
    func setupWallet(_ wallet: Wallet) throws {
        let chains = wallet.accounts.map { $0.chain }.asSet()
            .intersection(AssetConfiguration.allChains)
            .map { $0 }
        
        try enableAssetBalances(wallet: wallet, chains: chains)
    }
    
    func enableAssetBalances(wallet: Wallet, chains: [Chain]) throws {
        try walletService.addAssetsBalancesIfMissing(
            assetIds: chains.ids,
            wallet: wallet
        )
    }
    
    func hideAsset(for wallet: Wallet, _ assetId: AssetId) throws {
        try walletService.hideAsset(wallet: wallet, assetId: assetId)
    }
    
    func copyAssetAddress(for address: String) {
        UIPasteboard.general.string = address
    }
}
