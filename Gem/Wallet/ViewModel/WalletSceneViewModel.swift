import Foundation
import Keystore
import Primitives
import Store
import Settings
import UIKit

struct WalletSceneViewModel {

    let wallet: Wallet
    private let balanceService: BalanceService
    private let walletsService: WalletsService
    
    init(
        wallet: Wallet,
        balanceService: BalanceService,
        walletsService: WalletsService
    ) {
        self.wallet = wallet
        self.balanceService = balanceService
        self.walletsService = walletsService
    }

    var assetsPinnedRequest: AssetsRequest {
        AssetsRequest(walletID: wallet.id, filters: [.enabled, .includePinned(true)])
    }

    var assetsRequest: AssetsRequest {
        AssetsRequest(walletID: wallet.id, filters: [.enabled, .includePinned(false)])
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

    var bannersRequest: BannersRequest {
        BannersRequest(walletId: wallet.walletId.id, assetId: .none, events: [.enableNotifications])
    }

    func setupWallet() throws {
        try walletsService.setupWallet(wallet)
    }

    func fetch(walletId: WalletId, assets: [AssetData]) async throws {
        try await walletsService.fetch(
            walletId: walletId,
            assetIds: assets.map { $0.asset.id }
        )
    }

    func fetch(assets: [AssetData]) async throws {
        do {
            try await fetch(walletId: wallet.walletId, assets: assets)
        } catch {
            NSLog("fetch error: \(error)")
        }
    }

    func hideAsset(_ assetId: AssetId) throws {
        try walletsService.hideAsset(walletId: wallet.walletId, assetId: assetId)
    }

    func pinAsset(_ assetId: AssetId, value: Bool) throws {
        if value {
            try balanceService.pinAsset(walletId: wallet.walletId, assetId: assetId)
        } else {
            try balanceService.unpinAsset(walletId: wallet.walletId, assetId: assetId)
        }
    }

    func copyAssetAddress(for address: String) {
        UIPasteboard.general.string = address
    }
}
