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
import WalletService
import Formatters

@Observable
@MainActor
public final class WalletSceneViewModel: Sendable {
    private let walletsService: WalletsService
    private let bannerService: BannerService
    private let walletService: WalletService

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

    // TODO: - separate presenting sheet state logic to separate type
    public var isPresentingSelectedAssetInput: Binding<SelectedAssetInput?>
    public var isPresentingWallets = false
    public var isPresentingSelectAssetType: SelectAssetType?
    public var isPresentingInfoSheet: InfoSheetType?
    public var isPresentingUrl: URL? = nil
    public var isPresentingTransferData: TransferData?
    public var isPresentingPerpetualRecipientData: PerpetualRecipientData?
    public var isPresentingSetPriceAlert: AssetId?
    public var isPresentingToastMessage: ToastMessage?
    public var isPresentingSearch = false
    public var isPresentingAddToken: Bool = false

    public var isLoadingAssets: Bool = false

    public init(
        walletsService: WalletsService,
        bannerService: BannerService,
        walletService: WalletService,
        observablePreferences: ObservablePreferences,
        wallet: Wallet,
        isPresentingSelectedAssetInput: Binding<SelectedAssetInput?>
    ) {
        self.wallet = wallet
        self.walletsService = walletsService
        self.bannerService = bannerService
        self.walletService = walletService
        self.observablePreferences = observablePreferences

        self.totalFiatRequest = TotalValueRequest(walletId: wallet.id, balanceType: .wallet)
        self.assetsRequest = AssetsRequest(
            walletId: wallet.id,
            filters: [.enabledBalance]
        )
        self.bannersRequest = BannersRequest(
            walletId: wallet.id,
            assetId: .none,
            chain: .none,
            events: [
                .accountBlockedMultiSignature,
                .onboarding
            ]
        )
        self.isPresentingSelectedAssetInput = isPresentingSelectedAssetInput
    }

    public var currentWallet: Wallet? { walletService.currentWallet }

    var pinnedTitle: String { Localized.Common.pinned }
    var manageTokenTitle: String { Localized.Wallet.manageTokenList }
    var perpetualsTitle: String { Localized.Perpetuals.title }

    public var searchImage: Image { Images.System.search }
    public var manageImage: Image { Images.Actions.manage }

    var pinImage: Image { Images.System.pin }

    var showPinnedSection: Bool {
        !sections.pinned.isEmpty
    }

    var showPerpetuals: Bool {
        observablePreferences.isPerpetualEnabled && wallet.isMultiCoins
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
            currencyCode: currencyCode,
            bannerEventsViewModel: HeaderBannerEventViewModel(events: banners.map(\.event))
        )
    }

    var walletBannersModel: WalletSceneBannersViewModel {
        WalletSceneBannersViewModel(
            banners: banners,
            totalFiatValue: totalFiatValue
        )
    }
}

// MARK: - Business Logic

extension WalletSceneViewModel {
    func fetch() {
        Task {
            shouldStartLoadingAssets()
            await fetch(
                walletId: wallet.walletId,
                assetIds: assets.map { $0.asset.id }
            )
            isLoadingAssets = false
        }
    }
    
    public func onSelectWalletBar() {
        isPresentingWallets.toggle()
    }

    public func onSelectManage() {
        isPresentingSelectAssetType = .manage
    }

    public func onToggleSearch() {
        isPresentingSearch.toggle()
    }

    public func onSelectAddCustomToken() {
        isPresentingAddToken = true
    }

    func onHeaderAction(type: HeaderButtonType) {
        let selectType: SelectAssetType = switch type {
        case .buy: .buy
        case .send: .send
        case .receive: .receive(.asset)
        case .sell, .swap, .more, .stake, .deposit, .withdraw:
            fatalError()
        }
        isPresentingSelectAssetType = selectType
    }

    func onCloseBanner(banner: Banner) {
        bannerService.onClose(banner)
    }

    func onSelectWatchWalletInfo() {
        isPresentingInfoSheet = .watchWallet
    }

    func onBanner(action: BannerAction) {
        switch action.type {
        case .event, .closeBanner:
            Task { try await handleBanner(action: action) }
        case .button(let bannerButton):
            switch bannerButton {
            case .buy: isPresentingSelectAssetType = .buy
            case .receive: isPresentingSelectAssetType = .receive(.asset)
            }
        }
        isPresentingUrl = action.url
    }

    func onHideAsset(_ assetId: AssetId) {
        do {
            try walletsService.hideAsset(walletId: wallet.walletId, assetId: assetId)
        } catch {
            debugLog("WalletSceneViewModel hide Asset error: \(error)")
        }
    }

    func onPinAsset(_ asset: Asset, value: Bool) {
        do {
            try walletsService.setPinned(value, walletId: wallet.walletId, assetId: asset.id)
            isPresentingToastMessage = .pin(asset.name, pinned: value)
        } catch {
            debugLog("WalletSceneViewModel pin asset error: \(error)")
        }
    }

    func onCopyAddress(_ message: String) {
        isPresentingToastMessage = .copy(message)
    }

    public func onChangeWallet(_ oldWallet: Wallet?, _ newWallet: Wallet?) {
        if let newWallet, wallet != newWallet {
            refresh(for: newWallet)
        }
    }

    public func onWalletTabReselected(_: Bool, _: Bool) {
         isPresentingSearch = false
    }
    
    func shouldStartLoadingAssets() {
        let preferences = WalletPreferences(walletId: wallet.id)
        isLoadingAssets = !preferences.completeInitialLoadAssets && preferences.assetsTimestamp == .zero
    }
    
    public func onTransferComplete() {
        isPresentingTransferData = nil
    }
    
    public func onSetPriceAlertComplete(message: String) {
        isPresentingSetPriceAlert = nil
        isPresentingToastMessage = .priceAlert(message: message)
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
            debugLog("WalletSceneViewModel fetch error: \(error)")
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
