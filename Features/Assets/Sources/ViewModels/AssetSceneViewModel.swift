// Copyright (c). Gem Wallet. All rights reserved.

import AssetsService
import BannerService
import BigInt
import Components
import ExplorerService
import Formatters
import Gemstone
import Localization
import Preferences
import PriceAlertService
import PriceService
import Primitives
import PrimitivesComponents
import Style
import SwiftUI
import TransactionsService
import UIKit
import WalletsService
import YieldService

@Observable
@MainActor
public final class AssetSceneViewModel: Sendable {
    private let walletsService: WalletsService
    private let assetsService: AssetsService
    private let transactionsService: TransactionsService
    private let priceObserverService: PriceObserverService
    private let bannerService: BannerService
    private let yieldService: YieldService?

    private let preferences: ObservablePreferences = .default

    private(set) var hasYieldOpportunity: Bool = false
    private(set) var yieldPosition: GemYieldPosition?
    private(set) var isYieldPositionLoaded: Bool = false

    let explorerService: ExplorerService = .standard
    public let priceAlertService: PriceAlertService

    private var isPresentingSelectedAssetInput: Binding<SelectedAssetInput?>

    public var isPresentingToastMessage: ToastMessage?
    public var isPresentingAssetSheet: AssetSheetType?

    public var input: AssetSceneInput
    public var chainAssetData: ChainAssetData
    public var transactions: [TransactionExtended] = []
    public var banners: [Banner] = []
    public var assetData: AssetData { chainAssetData.assetData }
    private var asset: Asset { assetData.asset }
    private var wallet: Wallet { walletModel.wallet }

    public init(
        walletsService: WalletsService,
        assetsService: AssetsService,
        transactionsService: TransactionsService,
        priceObserverService: PriceObserverService,
        priceAlertService: PriceAlertService,
        bannerService: BannerService,
        yieldService: YieldService? = nil,
        input: AssetSceneInput,
        isPresentingSelectedAssetInput: Binding<SelectedAssetInput?>
    ) {
        self.walletsService = walletsService
        self.assetsService = assetsService
        self.transactionsService = transactionsService
        self.priceObserverService = priceObserverService
        self.priceAlertService = priceAlertService
        self.bannerService = bannerService
        self.yieldService = yieldService

        self.input = input
        self.chainAssetData = ChainAssetData(
            assetData: AssetData.with(asset: input.asset),
            feeAssetData: AssetData.with(asset: input.asset.chain.asset)
        )
        self.isPresentingSelectedAssetInput = isPresentingSelectedAssetInput
    }

    public var title: String { assetModel.name }

    var balancesTitle: String { Localized.Asset.balances }
    var networkTitle: String { Localized.Transfer.network }
    var stakeTitle: String { Localized.Wallet.stake }
    
    var resourcesTitle: String { Localized.Asset.resources }
    var energyTitle: String { ResourceViewModel(resource: .energy).title }
    var bandwidthTitle: String { ResourceViewModel(resource: .bandwidth).title }
    var energyText: String { feeAssetDataModel.energyText }
    var bandwidthText: String { feeAssetDataModel.bandwidthText }

    var canOpenNetwork: Bool { assetDataModel.asset.type != .native }

    var showBalances: Bool { assetDataModel.showBalances || hasYieldPosition }
    private var showStakedBalanceTypes: [BalanceType] = [.staked, .pending, .rewards]
    var showStakedBalance: Bool { assetDataModel.isStakeEnabled || assetData.balances.contains(where: { showStakedBalanceTypes.contains($0.key) && $0.value > 0 }) }
    var showReservedBalance: Bool { assetDataModel.hasReservedBalance }
    var showPendingUnconfirmedBalance: Bool { assetDataModel.hasPendingUnconfirmedBalance }
    var showResources: Bool { assetDataModel.showResources }

    var showTransactions: Bool { transactions.isNotEmpty }
    var showManageToken: Bool { !assetData.metadata.isBalanceEnabled }

    var canSign: Bool { wallet.canSign }

    var pinText: String {
        assetData.metadata.isPinned ? Localized.Common.unpin : Localized.Common.pin
    }
    var pinSystemImage: String {
        assetData.metadata.isPinned ? SystemImage.unpin : SystemImage.pin
    }
    var pinImage: Image {
        Image(systemName: pinSystemImage)
    }
    var enableText: String {
        assetData.metadata.isBalanceEnabled ? Localized.Asset.hideFromWallet : Localized.Asset.addToWallet
    }
    var enableImage: Image {
        Image(systemName: enableSystemImage)
    }
    var enableSystemImage: String {
        assetData.metadata.isBalanceEnabled ? SystemImage.minusCircle : SystemImage.plusCircle
    }
    
    var reservedBalanceUrl: URL? { assetModel.asset.chain.accountActivationFeeUrl }

    var networkText: String { assetModel.networkFullName }
    var stakeAprText: String {
        guard let apr = assetDataModel.stakingApr else { return .empty }
        return Localized.Stake.apr(CurrencyFormatter.percentSignLess.string(apr))
    }

    var earnTitle: String { "Earn" }

    var showStakeButton: Bool {
        !showBalances && assetDataModel.isStakeEnabled && !wallet.isViewOnly
    }

    var showEarnButton: Bool {
        hasYieldOpportunity && !wallet.isViewOnly && isYieldPositionLoaded && !hasYieldPosition
    }

    var hasYieldPosition: Bool {
        guard let position = yieldPosition,
              let balance = position.vaultBalanceValue.flatMap({ BigInt($0) }) else {
            return false
        }
        return balance > 0
    }

    var yieldBalanceText: String {
        guard let position = yieldPosition,
              let balance = position.assetBalanceValue.flatMap({ BigInt($0) }) else {
            return "0"
        }
        return ValueFormatter(style: .medium).string(balance, decimals: asset.decimals.asInt, currency: asset.symbol)
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

    var emptyContentModel: EmptyContentTypeViewModel {
        let buy = assetData.metadata.isBuyEnabled ? onSelectBuy : nil
        let swap = buy == nil && assetData.metadata.isSwapEnabled ? onSelectSwap : nil
        return EmptyContentTypeViewModel(
            type: .asset(symbol: assetModel.symbol, buy: buy, swap: swap, isViewOnly: wallet.isViewOnly)
        )
    }

    var assetDataModel: AssetDataViewModel {
        AssetDataViewModel(
            assetData: assetData,
            formatter: .medium,
            currencyCode: preferences.preferences.currency
        )
    }
    
    var assetBannerViewModel: AssetSceneBannersViewModel {
        AssetSceneBannersViewModel(assetData: assetData, banners: banners)
    }
    
    var assetHeaderModel: AssetHeaderViewModel {
        AssetHeaderViewModel(
            assetDataModel: assetDataModel,
            walletModel: walletModel,
            bannerEventsViewModel: HeaderBannerEventViewModel(events: assetBannerViewModel.allBanners.map(\.event))
        )
    }

    public var shareAssetUrl: URL { DeepLink.asset(assetDataModel.asset.id).url }
    public var assetModel: AssetViewModel { AssetViewModel(asset: assetData.asset) }
    public var walletModel: WalletViewModel { WalletViewModel(wallet: input.wallet) }

    public var optionsImage: Image { Images.System.ellipsis }
    public var priceAlertsSystemImage: String { assetData.isPriceAlertsEnabled ? SystemImage.bellFill : SystemImage.bell }
    public var priceAlertsImage: Image { Image(systemName: priceAlertsSystemImage) }
    public var showPriceAlerts: Bool { priceAlertsViewModel.hasPriceAlerts && assetDataModel.isPriceAvailable }

    public var menuItems: [ActionMenuItemType] {
        [.button(title: viewAddressOnTitle, systemImage: SystemImage.globe, action: { self.onSelect(url: self.addressExplorerUrl) }),
         viewTokenOnTitle.map { .button(title: $0, systemImage: SystemImage.globe, action: { self.onSelect(url: self.tokenExplorerUrl) })},
         .button(title: Localized.Common.share, systemImage: SystemImage.share, action: onSelectShareAsset)].compactMap { $0 }
    }

    var scoreViewModel: AssetScoreTypeViewModel {
        AssetScoreTypeViewModel(score: assetData.metadata.rankScore)
    }

    var showStatus: Bool {
        scoreViewModel.hasWarning
    }
    
    var priceAlertsViewModel: PriceAlertsViewModel {
        PriceAlertsViewModel(priceAlerts: assetData.priceAlerts)
    }
    
    var swapAssetType: SelectedAssetType {
        switch assetData.asset.id.type {
        case .native: .swap(assetData.asset, nil)
        case .token:
            if assetData.balance.available == .zero {
                .swap(assetData.asset.chain.asset, assetData.asset)
            } else {
                .swap(assetData.asset, nil)
            }
        }
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
        checkYieldAvailability()

        if assetData.priceAlerts.isNotEmpty {
            Task {
                try await priceAlertService.update(assetId: asset.id.identifier)
            }
        }
    }

    private func checkYieldAvailability() {
        guard let _ = yieldService, assetData.isEarnable else { return }
        hasYieldOpportunity = true
        fetchYieldPosition()
    }

    private func fetchYieldPosition() {
        guard let yieldService,
              let address = try? wallet.account(for: asset.id.chain).address else {
            isYieldPositionLoaded = true
            return
        }

        yieldPosition = yieldService.getPosition(
            provider: .yo,
            asset: asset.id,
            walletAddress: address,
            walletId: wallet.walletId
        ) { [weak self] fresh in
            self?.yieldPosition = fresh
        }
        isYieldPositionLoaded = true
    }

    func fetch() async {
        await updateWallet()
    }

    func onSelectHeader(_ buttonType: HeaderButtonType) {
        let selectType: SelectedAssetType = switch buttonType {
        case .buy: .buy(assetData.asset, amount: nil)
        case .sell: .sell(assetData.asset, amount: nil)
        case .send: .send(.asset(assetData.asset))
        case .swap: swapAssetType
        case .receive: .receive(.asset)
        case .stake: .stake(assetData.asset)
        case .more, .deposit, .withdraw:
            fatalError()
        }
        isPresentingSelectedAssetInput.wrappedValue = SelectedAssetInput(
            type: selectType,
            assetAddress: assetData.assetAddress
        )
    }

    func onSelectWalletHeaderInfo() {
        isPresentingAssetSheet = .info(.watchWallet)
    }

    func onSelectBanner(_ action: BannerAction) {
        switch action.type {
        case .event(let event):
            switch event {
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
                        value: 0
                    )
                )
            case .enableNotifications,
                    .accountActivation,
                    .accountBlockedMultiSignature,
                    .onboarding:
                Task {
                    try await bannerService.handleAction(action)
                }
            case .suspiciousAsset: break
            case .tradePerpetuals:
                UIApplication.shared.open(DeepLink.perpetuals.localUrl)
                preferences.isPerpetualEnabled = true
            case .yield:
                onSelectEarn()
            }
        case .button(let bannerButton):
            switch bannerButton {
            case .buy: onSelectHeader(.buy)
            case .receive: onSelectHeader(.receive)
            }
        case .closeBanner:
            Task {
                try await bannerService.handleAction(action)
            }
        }
        onSelect(url: action.url)
    }

    func onSelectBuy() {
        onSelectHeader(.buy)
    }

    func onSelectSwap() {
        onSelectHeader(.swap)
    }

    func onSelectEarn() {
        isPresentingSelectedAssetInput.wrappedValue = SelectedAssetInput(
            type: .earn(assetData.asset),
            assetAddress: assetData.assetAddress
        )
    }

    public func onSelectShareAsset() {
        isPresentingAssetSheet = .share
    }

    public func onTransferComplete() {
        isPresentingAssetSheet = .none
    }

    public func onTogglePriceAlert() {
        Task {
            let enabled = !assetData.isPriceAlertsEnabled
            isPresentingToastMessage = .priceAlert(for: assetData.asset.name, enabled: enabled)
            if enabled {
                await enablePriceAlert()
            } else {
                await disablePriceAlert()
            }
        }
    }
    
    public func onSelectTokenStatus() {
        isPresentingAssetSheet = .info(.assetStatus(scoreViewModel.scoreType))
    }

    public func onSelectPendingUnconfirmedInfo() {
        isPresentingAssetSheet = .info(.pendingUnconfirmedBalance)
    }
    
    public func onSelectPin() {
        do {
            let pinned = !assetData.metadata.isPinned
            isPresentingToastMessage = .pin(asset.name, pinned: pinned)
            try walletsService.setPinned(pinned, walletId: wallet.walletId, assetId: asset.id)
            if !assetData.metadata.isBalanceEnabled {
                onSelectEnable()
            }
        } catch {
            debugLog("onSelectPin error: \(error)")
        }
    }

    public func onSelectEnable() {
        Task {
            let enabled = !assetData.metadata.isBalanceEnabled
            isPresentingToastMessage = .showAsset(visible: enabled)
            await walletsService.enableAssets(walletId: wallet.walletId, assetIds: [asset.id], enabled: enabled)
        }
    }
}

// MARK: - Private

extension AssetSceneViewModel {
    private var addressExplorerUrl: URL { addressLink.url }
    private var viewAddressOnTitle: String { Localized.Asset.viewAddressOn(addressLink.name) }
    private var viewTokenOnTitle: String? {
        if let link = tokenLink {
            return Localized.Asset.viewTokenOn(link.name)
        }
        return .none
    }

    private var tokenExplorerUrl: URL? { tokenLink?.url }
    private var tokenLink: BlockExplorerLink? {
        guard let tokenId = assetModel.asset.tokenId else {
            return .none
        }
        return explorerService.tokenUrl(chain: assetModel.asset.chain, address: tokenId)
    }

    private var addressLink: BlockExplorerLink {
        explorerService.addressUrl(chain: assetModel.asset.chain, address: assetDataModel.address)
    }

    private var feeAssetDataModel: AssetDataViewModel {
        AssetDataViewModel(
            assetData: chainAssetData.feeAssetData,
            formatter: .medium,
            currencyCode: preferences.preferences.currency
        )
    }

    private func onSelect(url: URL?) {
        guard let url else { return }
        isPresentingAssetSheet = .url(url)
    }

    private func fetchTransactions() async throws {
        do {
            try await transactionsService.updateForAsset(wallet: walletModel.wallet, assetId: assetModel.asset.id)
        } catch {
            // TODO: - handle fetchTransactions error
            debugLog("asset scene: fetchTransactions error \(error)")
        }
    }

    private func enablePriceAlert() async {
        do {
            try await priceAlertService.add(priceAlert: .default(for: assetModel.asset.id, currency: Preferences.standard.currency))
            try await priceAlertService.requestPermissions()
            try await priceAlertService.enablePriceAlerts()
        } catch {
            debugLog("enablePriceAlert error \(error)")
        }
    }

    private func disablePriceAlert() async {
        do {
            try await priceAlertService.delete(priceAlerts: [.default(for: assetModel.asset.id, currency: Preferences.standard.currency)])
        } catch {
            debugLog("disablePriceAlert error \(error)")
        }
    }

    private func updateAsset() async {
        do {
            try await assetsService.updateAsset(assetId: assetModel.asset.id)
            checkYieldAvailability()
        } catch {
            // TODO: - handle updateAsset error
            debugLog("asset scene: updateAsset error \(error)")
        }

        Task {
            do {
                try await priceObserverService.addAssets(assets: [assetModel.asset.id])
            } catch {
                debugLog("asset scene: priceObserverService.addAssets error \(error)")
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
            debugLog("asset scene: updateWallet error \(error)")
        }
    }
}
