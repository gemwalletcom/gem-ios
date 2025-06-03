// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI
import Components
import Style
import Localization
import PriceAlertService
import PrimitivesComponents
import Preferences
import ExplorerService
import AssetsService
import TransactionsService
import WalletsService
import PriceService
import InfoSheet
import BannerService

@Observable
@MainActor
final class AssetSceneViewModel: Sendable {
    private let walletsService: WalletsService
    private let assetsService: AssetsService
    private let transactionsService: TransactionsService
    private let priceObserverService: PriceObserverService
    private let bannerService: BannerService

    private let securePreferences: SecurePreferences = .standard
    private let preferences: ObservablePreferences = .default

    let explorerService: ExplorerService = .standard
    let priceAlertService: PriceAlertService

    private var isPresentingAssetSelectedInput: Binding<SelectedAssetInput?>

    var isPresentingOptions: Bool?
    var isPresentingToastMessage: String?
    var isPresentingAssetSheet: AssetSheetType?

    var input: AssetSceneInput
    var assetData: AssetData
    var transactions: [TransactionExtended] = []
    var banners: [Banner] = []

    init(
        walletsService: WalletsService,
        assetsService: AssetsService,
        transactionsService: TransactionsService,
        priceObserverService: PriceObserverService,
        priceAlertService: PriceAlertService,
        bannerService: BannerService,
        input: AssetSceneInput,
        isPresentingAssetSelectedInput: Binding<SelectedAssetInput?>
    ) {
        self.walletsService = walletsService
        self.assetsService = assetsService
        self.transactionsService = transactionsService
        self.priceObserverService = priceObserverService
        self.priceAlertService = priceAlertService
        self.bannerService = bannerService

        self.input = input
        self.assetData = AssetData.with(asset: input.asset)
        _isPresentingAssetSelectedInput = isPresentingAssetSelectedInput
    }

    var title: String { assetModel.name }
    var viewAddressOnTitle: String { Localized.Asset.viewAddressOn(addressLink.name) }
    var viewTokenOnTitle: String? {
        if let link = tokenLink {
            return Localized.Asset.viewTokenOn(link.name)
        }
        return .none
    }
    var balancesTitle: String { Localized.Asset.Balances.available }
    var networkTitle: String { Localized.Transfer.network }
    var stakeTitle: String { Localized.Wallet.stake }

    var addImage: Image { Images.System.plus }
    var optionsImage: Image { Images.System.ellipsis }
    var priceAlertsSystemImage: String { assetData.isPriceAlertsEnabled ? SystemImage.bellFill : SystemImage.bell }
    var priceAlertsImage: Image { Image(systemName: priceAlertsSystemImage) }

    var isDeveloperEnabled: Bool { preferences.isDeveloperEnabled }
    var canOpenNetwork: Bool { assetDataModel.asset.type != .native }
    var showBalances: Bool { assetDataModel.showBalances }
    var showStakedBalance: Bool { assetDataModel.isStakeEnabled }
    var showReservedBalance: Bool { assetDataModel.hasReservedBalance }
    var showTransactions: Bool { transactions.isNotEmpty }

    var reservedBalanceUrl: URL? { assetModel.asset.chain.accountActivationFeeUrl }
    var shareAssetUrl: URL { DeepLink.asset(assetDataModel.asset.id).url }
    var addressExplorerUrl: URL { addressLink.url }
    var tokenExplorerUrl: URL? { tokenLink?.url }

    var networkText: String { assetModel.networkFullName }
    var stakeAprText: String {
        guard let apr = assetDataModel.stakeApr else { return .empty }
        return Localized.Stake.apr(CurrencyFormatter(type: .percentSignLess).string(apr))
    }

    var priceItemViewModel: PriceListItemViewModel {
        PriceListItemViewModel(
            title: Localized.Asset.price,
            model: assetDataModel.priceViewModel
        )
    }

    var networkAssetImage: AssetImage {
        AssetIdViewModel(assetId: assetModel.asset.chain.assetId).networkAssetImage
    }

    var emptyConentModel: EmptyContentTypeViewModel {
        EmptyContentTypeViewModel(type: .asset(symbol: assetModel.symbol, buy: onSelectBuy))
    }

    var assetModel: AssetViewModel {
        AssetViewModel(asset: assetData.asset)
    }

    var assetDataModel: AssetDataViewModel {
        AssetDataViewModel(
            assetData: assetData,
            formatter: .medium,
            currencyCode: preferences.preferences.currency
        )
    }

    var walletModel: WalletViewModel {
        WalletViewModel(wallet: input.wallet)
    }

    var assetHeaderModel: AssetHeaderViewModel {
        let allBanners = (assetDataModel.isActive ? [] : [Banner(wallet: .none,
                                                                 asset: assetDataModel.asset,
                                                                 chain: .none,
                                                                 event: .activateAsset,
                                                                 state: .alwaysActive)]) + banners
        return AssetHeaderViewModel(
            assetDataModel: assetDataModel,
            walletModel: walletModel,
            bannerEventsViewModel: HeaderBannerEventViewModel(events: allBanners.map(\.event))
        )
    }
}


// MARK: - Business Logic

extension AssetSceneViewModel {
    func fetchOnce() {
        Task {
            await fetch()
        }
        Task {
            await updateAsset()
        }
    }

    func fetch() async {
        await updateWallet()
    }

    func onSelectHeader(_ buttonType: HeaderButtonType) {
        let selectType: SelectedAssetType = switch buttonType {
        case .buy: .buy(assetData.asset)
        case .send: .send(.asset(assetData.asset))
        case .swap: .swap(assetData.asset)
        case .receive: .receive(.asset)
        case .stake: .stake(assetData.asset)
        case .more:
            fatalError()
        }
        isPresentingAssetSelectedInput.wrappedValue = SelectedAssetInput(
            type: selectType,
            assetAddress: assetData.assetAddress
        )
    }

    func onSelectWalletHeaderInfo() {
        isPresentingAssetSheet = .info(.watchWallet)
    }

    func onSelectBanner(_ banner: Banner) {
        let action = BannerViewModel(banner: banner).action
        switch banner.event {
        case .stake:
            onSelectHeader(.stake)
        case .activateAsset:
            isPresentingAssetSheet = .transfer(
                TransferData(
                    type: .account(assetData.asset, .activate),
                    recipientData: RecipientData(
                        recipient: Recipient(
                            name: .none,
                            address: "",
                            memo: .none
                        ),
                        amount: .none
                    ),
                    value: 0,
                    canChangeValue: false,
                    ignoreValueCheck: true
                )
            )
        case .enableNotifications,
                .accountActivation,
                .accountBlockedMultiSignature:
            Task {
                try await bannerService.handleAction(action)
            }
        }
        onSelect(url: action.url)
    }

    func onCloseBanner(_ banner: Banner) {
        bannerService.onClose(banner)
    }

    func onSelectBuy() {
        isPresentingAssetSelectedInput.wrappedValue = SelectedAssetInput(
            type: .buy(assetModel.asset),
            assetAddress: assetDataModel.assetAddress
        )
    }

    func onSelectSetPriceAlerts() {
        isPresentingAssetSheet = .setPriceAlert
    }

    func onTogglePriceAlert() {
        Task {
            if assetData.isPriceAlertsEnabled {
                isPresentingToastMessage = Localized.PriceAlerts.disabledFor(assetData.asset.name)
                await disablePriceAlert()
            } else {
                isPresentingToastMessage = Localized.PriceAlerts.enabledFor(assetData.asset.name)
                await enablePriceAlert()
            }
        }
    }

    func onSelectOptions() {
        isPresentingOptions = true
    }

    func onSelectShareAsset() {
        isPresentingAssetSheet = .share
    }

    func onSelect(url: URL?) {
        guard let url else { return }
        isPresentingAssetSheet = .url(url)
    }

    func onTransferComplete() {
        isPresentingAssetSheet = .none
    }

    func onSetPriceAlertComplete(message: String) {
        isPresentingAssetSheet = .none
        isPresentingToastMessage = message
    }
}

// MARK: - Private

extension AssetSceneViewModel {
    private var tokenLink: BlockExplorerLink? {
        guard let tokenId = assetModel.asset.tokenId else {
            return .none
        }
        return explorerService.tokenUrl(chain: assetModel.asset.chain, address: tokenId)
    }

    private var addressLink: BlockExplorerLink {
        explorerService.addressUrl(chain: assetModel.asset.chain, address: assetDataModel.address)
    }

    private func fetchTransactions() async throws {
        do {
            guard let deviceId = try securePreferences.get(key: .deviceId) else {
                throw AnyError("deviceId is null")
            }
            try await transactionsService.updateForAsset(deviceId: deviceId, wallet: walletModel.wallet, assetId: assetModel.asset.id)
        } catch {
            // TODO: - handle fetchTransactions error
            print("asset scene: fetchTransactions error \(error)")
        }
    }

    private func enablePriceAlert() async {
        do {
            try await priceAlertService.add(priceAlert: .default(for: assetModel.asset.id, currency: Preferences.standard.currency))
            try await priceAlertService.requestPermissions()
            try await priceAlertService.enablePriceAlerts()
        } catch {
            NSLog("enablePriceAlert error \(error)")
        }
    }

    private func disablePriceAlert() async {
        do {
            try await priceAlertService.delete(priceAlerts: [.default(for: assetModel.asset.id, currency: Preferences.standard.currency)])
        } catch {
            NSLog("disablePriceAlert error \(error)")
        }
    }

    private func updateAsset() async {
        do {
            try await assetsService.updateAsset(assetId: assetModel.asset.id)
        } catch {
            // TODO: - handle updateAsset error
            print("asset scene: updateAsset error \(error)")
        }

        Task {
            do {
                try await priceObserverService.addAssets(assets: [assetModel.asset.id])
            } catch {
                // TODO: - handle priceObserverService.addAssets error
                print("asset scene: priceObserverService.addAssets error \(error)")
            }
        }
    }

    private func updateWallet() async {
        do {
            async let updateAsset: () = try walletsService.updateAssets(
                walletId: walletModel.wallet.walletId,
                assetIds: [assetModel.asset.id]
            )
            async let updateTransactions: () = try fetchTransactions()
            let _ = try await [updateAsset, updateTransactions]
        } catch {
            // TODO: - handle fetch error
            print("asset scene: updateWallet error \(error)")
        }
    }
}
