// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization
import UIKit
import SwiftUI
import Style
import Primitives
import BalanceService
import WalletsService
import BannerService
import Store
import Preferences
@preconcurrency import Keystore

// TODO: - services to private,
// use on instance of wallet, now we use wallet + keysotre getting wallet
// move business logic from view to view model

public struct WalletSceneViewModel: Sendable {
    public let wallet: Wallet

    let observablePreferences: ObservablePreferences
    let keystore: any Keystore
    let walletsService: WalletsService
    let bannerService: BannerService

    private let balanceService: BalanceService

    public init(
        wallet: Wallet,
        balanceService: BalanceService,
        walletsService: WalletsService,
        bannerService: BannerService,
        observablePreferences: ObservablePreferences,
        keystore: any Keystore
    ) {
        self.wallet = wallet
        self.balanceService = balanceService
        self.walletsService = walletsService
        self.bannerService = bannerService
        self.observablePreferences = observablePreferences
        self.keystore = keystore
    }

    var pinImage: Image {
        Images.System.pin
    }

    var pinnedTitle: String {
        Localized.Common.pinned
    }

    var manageTokenTitle: String {
        Localized.Wallet.manageTokenList
    }

    var manageImage: Image {
        Images.Actions.manage
    }

    var assetsRequest: AssetsRequest {
        AssetsRequest(walletID: wallet.id, filters: [.enabled])
    }

    var totalFiatValueRequest: TotalValueRequest {
        TotalValueRequest(walletID: wallet.id)
    }

    var recentTransactionsRequest: TransactionsRequest {
        TransactionsRequest(walletId: wallet.id, type: .pending, limit: 3)
    }

    var walletRequest: WalletRequest {
        WalletRequest(walletId: wallet.id)
    }

    var bannersRequest: BannersRequest {
        BannersRequest(
            walletId: wallet.walletId.id,
            assetId: .none,
            chain: .none,
            events: [
                .enableNotifications,
                .accountBlockedMultiSignature,
            ]
        )
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
