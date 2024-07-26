import Foundation
import Keystore
import Primitives
import Store
import Settings
import UIKit

struct WalletSceneViewModel {

    let wallet: Wallet
    private let walletService: WalletService
    
    init(
        wallet: Wallet,
        walletService: WalletService
    ) {
        self.wallet = wallet
        self.walletService = walletService
    }

    var assetsRequest: AssetsRequest {
        AssetsRequest(walletID: wallet.id, chains: [], filters: [.enabled])
    }

    var fiatValueRequest: TotalValueRequest {
        TotalValueRequest(walletID: wallet.id)
    }

    var recentTransactionsRequest: TransactionsRequest {
        TransactionsRequest(walletId: wallet.id, type: .pending, limit: 3)
    }

    var walletRequest: WalletRequest {
        WalletRequest(walletId: wallet.id)
    }

    func setupWallet() throws {
        try walletService.setupWallet(wallet)
    }

    func fetch(walletId: WalletId, assets: [AssetData]) async throws {
        NSLog("wallet fetch for: \(walletId.id)")
        NSLog("wallet fetch for: \(wallet.id), \(wallet.name)")

        try await walletService.fetch(
            walletId: walletId,
            assetIds: assets.map { $0.asset.id }
        )
    }

    func fetch(assets: [AssetData]) async throws {
        NSLog("wallet fetch for: \(wallet.name)")

        do {
            try await fetch(walletId: wallet.walletId, assets: assets)
        } catch {
            NSLog("fetch error: \(error)")
        }
    }

    func hideAsset(_ assetId: AssetId) throws {
        try walletService.hideAsset(walletId: wallet.walletId, assetId: assetId)
    }

    func copyAssetAddress(for address: String) {
        UIPasteboard.general.string = address
    }
}
