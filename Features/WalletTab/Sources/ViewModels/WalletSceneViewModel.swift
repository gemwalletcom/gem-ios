// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import Primitives
import WalletsService
import BannerService
import Store
import Preferences
import Localization
import PrimitivesComponents
import InfoSheet
import Components
import ManageWalletService

@Observable
@MainActor
public final class WalletSceneViewModel: Sendable {
    private let walletsService: WalletsService
    private let bannerService: BannerService
    private let manageWalletService: ManageWalletService

    let observablePreferences: ObservablePreferences

    public var wallet: Wallet

    // db ovservation
    public var totalFiatRequest: TotalValueRequest
    public var assetsRequest: AssetsRequest
    public var bannersRequest: BannersRequest

    // db observered values
    public var totalFiatValue: Double = .zero
    public var assets: [AssetData] = []
    public var banners: [Banner] = []

    public var isPresentingWallets = false
    public var isPresentingSelectAssetType: SelectAssetType?
    public var isPresentingInfoSheet: InfoSheetType?

    public init(
        walletsService: WalletsService,
        bannerService: BannerService,
        manageWalletService: ManageWalletService,
        observablePreferences: ObservablePreferences,
        wallet: Wallet
    ) {
        self.wallet = wallet
        self.walletsService = walletsService
        self.bannerService = bannerService
        self.manageWalletService = manageWalletService
        self.observablePreferences = observablePreferences

        self.totalFiatRequest = TotalValueRequest(walletId: wallet.id)
        self.assetsRequest = AssetsRequest(
            walletId: wallet.id,
            filters: [.enabled]
        )
        self.bannersRequest = BannersRequest(
            walletId: wallet.id,
            assetId: .none,
            chain: .none,
            events: [
                .enableNotifications,
                .accountBlockedMultiSignature,
            ]
        )

    }

    public var currentWallet: Wallet? { manageWalletService.currentWallet }

    var pinnedTitle: String { Localized.Common.pinned }
    var manageTokenTitle: String { Localized.Wallet.manageTokenList }

    var pinImage: Image { Images.System.pin }
    public var manageImage: Image { Images.Actions.manage }

    var showPinnedSection: Bool {
        !sections.pinned.isEmpty
    }

    var currencyCode: String {
        observablePreferences.preferences.currency
    }

    var sections: AssetsSections {
        AssetsSections.from(assets)
    }

    public var walletBarModel: WalletBarViewViewModel {
        let walletModel = WalletViewModel(wallet: wallet)
        return WalletBarViewViewModel(
            name: walletModel.name,
            image: walletModel.avatarImage
        )
    }

    var walletHeaderModel: WalletHeaderViewModel {
        WalletHeaderViewModel(
            walletType: wallet.type,
            value: totalFiatValue,
            currencyCode: currencyCode
        )
    }
}

// MARK: - Business Logic

extension WalletSceneViewModel {
    func fetch() {
        Task {
            await fetch(
                walletId: wallet.walletId,
                assetIds: assets.map { $0.asset.id }
            )
        }
    }

    func updatePrices() async {
        do {
            try await walletsService.updatePrices()
        } catch {
            NSLog("WalletSceneViewModel updatePrices error: \(error)")
        }
    }
    
    public func onSelectWalletBar() {
        isPresentingWallets.toggle()
    }

    public func onSelectManage() {
        isPresentingSelectAssetType = .manage
    }

    func onHeaderAction(type: HeaderButtonType) {
        let selectType: SelectAssetType = switch type {
        case .buy: .buy
        case .send: .send
        case .receive: .receive(.asset)
        case .swap, .more, .stake:
            fatalError()
        }
        isPresentingSelectAssetType = selectType
    }

    func onCloseBanner(banner: Banner) {
        bannerService.onClose(banner)
    }

    func onCopyAssetAddress(_ address: String) {
        UIPasteboard.general.string = address
    }

    func onSelectWatchWalletInfo() {
        isPresentingInfoSheet = .watchWallet
    }

    func onBannerAction(banner: Banner) {
        let action = BannerViewModel(banner: banner).action
        switch banner.event {
        case .stake,
                .enableNotifications,
                .accountActivation,
                .accountBlockedMultiSignature,
                .activateAsset:
            Task {
                try await handleBanner(action: action)
            }
        }
    }

    func onHideAsset(_ assetId: AssetId) {
        do {
            try walletsService.hideAsset(walletId: wallet.walletId, assetId: assetId)
        } catch {
            NSLog("WalletSceneViewModel hide Asset error: \(error)")
        }
    }

    func onPinAsset(_ assetId: AssetId, value: Bool) {
        do {
            try walletsService.togglePin(value, walletId: wallet.walletId, assetId: assetId)
        } catch {
            NSLog("WalletSceneViewModel pin asset error: \(error)")
        }
    }

    public func onChangeWallet(_ oldWallet: Wallet?, _ newWallet: Wallet?) {
        if let newWallet, wallet != newWallet {
            refresh(for: newWallet)
        }
    }
}


// MARK: - Private

extension WalletSceneViewModel {
    private func fetch(
        walletId: WalletId,
        assetIds: [AssetId]
    ) async {
        do {
            try await walletsService.fetch(
                walletId: walletId,
                assetIds: assetIds
            )
        } catch {
            NSLog("WalletSceneViewModel fetch error: \(error)")
        }
    }

    private func refresh(for newWallet: Wallet) {
        wallet = newWallet
        totalFiatRequest.walletId = newWallet.id
        assetsRequest.walletId = newWallet.id
        bannersRequest.walletId = newWallet.id

        fetch()
    }

    private func handleBanner(action: BannerAction) async throws {
        try await bannerService.handleAction(action)
    }
}
