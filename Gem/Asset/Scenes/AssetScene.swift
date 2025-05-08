// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import GRDB
import GRDBQuery
import Store
import Style
import Localization
import InfoSheet
import PrimitivesComponents
import Preferences
import PriceAlerts

struct AssetScene: View {
    @Environment(\.walletsService) private var walletsService
    @Environment(\.assetsService) private var assetsService
    @Environment(\.transactionsService) private var transactionsService
    @Environment(\.bannerService) private var bannerService
    @Environment(\.priceObserverService) private var priceObserverService
    @Environment(\.priceAlertService) private var priceAlertService

    @State private var showingOptions = false
    @State private var isPresentingToast = false
    @State private var isPresentingToastMessage: String?
    @State private var isPresentingShareAssetSheet = false
    @State private var isPresentingInfoSheet: InfoSheetType? = .none
    @State private var isPresentingSetPriceAlert: Bool = false
    @State private var isPresentingUrl: URL? = nil

    @Binding private var isPresentingAssetSelectedInput: SelectedAssetInput?

    @Query<TransactionsRequest>
    private var transactions: [TransactionExtended]

    @Query<AssetRequest>
    private var assetData: AssetData

    @Query<BannersRequest>
    private var banners: [Primitives.Banner]
    
    private let walletModel: WalletViewModel
    private let onAssetActivate: AssetAction

    private var headerModel: AssetHeaderViewModel {
        AssetHeaderViewModel(
            assetDataModel: AssetDataViewModel(
                assetData: assetData,
                formatter: .medium,
                currencyCode: Preferences.standard.currency
            ),
            walletModel: walletModel,
            bannerEventsViewModel: HeaderBannerEventViewModel(events: (model.banners + banners).map { $0.event })
        )
    }
    
    private var model: AssetSceneViewModel {
        return AssetSceneViewModel(
            walletsService: walletsService,
            assetsService: assetsService,
            transactionsService: transactionsService,
            priceObserverService: priceObserverService,
            priceAlertService: priceAlertService,
            assetDataModel: AssetDataViewModel(
                assetData: assetData,
                formatter: .medium,
                currencyCode: Preferences.standard.currency
            ),
            walletModel: walletModel,
            isPresentingAssetSelectedInput: $isPresentingAssetSelectedInput
        )
    }

    init(
        wallet: Wallet,
        input: AssetSceneInput,
        isPresentingAssetSelectedInput: Binding<SelectedAssetInput?>,
        onAssetActivate: AssetAction
    ) {
        self.walletModel = WalletViewModel(wallet: wallet)
        self.onAssetActivate = onAssetActivate
        _isPresentingAssetSelectedInput = isPresentingAssetSelectedInput
        _assetData = Query(constant: input.assetRequest)
        _transactions = Query(constant: input.transactionsRequest)
        _banners = Query(constant: input.bannersRequest)
    }

    var body: some View {
        List {
            Section { } header: {
                WalletHeaderView(
                    model: headerModel,
                    isHideBalanceEnalbed: .constant(false),
                    onHeaderAction: onSelectHeader(_:),
                    onInfoAction: onSelectWalletHeaderInfo
                )
                    .padding(.top, .small)
                    .padding(.bottom, .medium)
            }
            .cleanListRow()

            Section {
                BannerView(banners: model.banners, action: onBannerAction, closeAction: bannerService.onClose)
            }
                        
            Section {
                NavigationLink(value: Scenes.Price(asset: model.assetModel.asset)) {
                    PriceListItemView(model: model.priceItemViewModel)
                }
                .accessibilityIdentifier("price")
                
                if model.showNetwork {
                    if model.openNetwork {
                        NavigationLink(value: Scenes.Asset(asset: model.assetModel.asset.chain.asset)) {
                            networkView
                        }
                    } else {
                        networkView
                    }
                }
            }

            if model.showBalances {
                Section(Localized.Asset.balances) {
                    ListItemView(title: Localized.Asset.Balances.available, subtitle: model.assetDataModel.availableBalanceTextWithSymbol)

                    if model.showStakedBalance {
                        stakeView
                    }

                    if model.showReservedBalance, let url = model.reservedBalanceUrl {
                        SafariNavigationLink(url: url) {
                            ListItemView(
                                title: Localized.Asset.Balances.reserved,
                                subtitle: model.assetDataModel.reservedBalanceTextWithSymbol
                            )
                        }
                    }
                }
            } else if model.assetDataModel.isStakeEnabled {
                stakeViewEmpty
            }

            if !transactions.isEmpty {
                TransactionsList(
                    explorerService: model.explorerService,
                    transactions
                )
                .listRowInsets(.assetListRowInsets)
            } else {
                Section {
                    Spacer()
                    EmptyContentView(model: model.emptyConentModel)
                }
                .cleanListRow()
            }
        }
        .refreshable {
            await fetch()
        }
        .toast(
            isPresenting: $isPresentingToast,
            title: isPresentingToastMessage.or(.empty),
            systemImage: assetData.priceAlertSystemImage
        )
        .onChange(of: isPresentingToastMessage, { oldValue, newValue in
            if newValue != nil {
                isPresentingToast = true
            }
        })
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    if Preferences.standard.isDeveloperEnabled {
                        Button(action: onSelectSetPriceAlerts) {
                            Image(systemName: SystemImage.plus)
                        }
                    }
                    Button(action: onPriceAlertToggle) {
                        Image(systemName: assetData.priceAlertSystemImage)
                    }
                    Button(action: onSelectOptions) {
                        Images.System.ellipsis
                    }
                    .confirmationDialog("", isPresented: $showingOptions, titleVisibility: .hidden) {
                        Button(model.viewAddressOnTitle) { isPresentingUrl = model.addressExplorerUrl }
                        if let title = model.viewTokenOnTitle {
                            Button(title) { isPresentingUrl = model.tokenExplorerUrl }
                        }
                        Button(Localized.Common.share) {
                            isPresentingShareAssetSheet = true
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isPresentingShareAssetSheet) {
            ShareSheet(activityItems: [model.shareAssetUrl.absoluteString])
        }
        .taskOnce(onTaskOnce)
        .listSectionSpacing(.compact)
        .navigationTitle(model.title)
        .sheet(item: $isPresentingInfoSheet) {
            InfoSheetScene(model: InfoSheetViewModel(type: $0))
        }
        .sheet(isPresented: $isPresentingSetPriceAlert) {
            SetPriceAlertNavigationStack(
                model: SetPriceAlertViewModel(
                    wallet: model.walletModel.wallet,
                    assetId: model.assetModel.asset.id,
                    priceAlertService: priceAlertService,
                    onComplete: {
                        isPresentingSetPriceAlert = false
                        isPresentingToastMessage = $0
                    }
                )
            )
        }
        .safariSheet(url: $isPresentingUrl)
    }
}

// MARK: - UI Components

extension AssetScene {
    private var networkView: some View {
        ListItemImageView(
            title: model.networkField,
            subtitle: model.networkText,
            assetImage: model.networkAssetImage,
            imageSize: .list.image
        )
    }

    private var stakeView: some View {
        NavigationCustomLink(with: ListItemView(title: Localized.Wallet.stake, subtitle: model.assetDataModel.stakeBalanceTextWithSymbol)) {
            onSelectHeader(.stake)
        }
        .accessibilityIdentifier("stake")
    }
    
    private var stakeViewEmpty: some View {
        NavigationCustomLink(
            with: HStack {
                EmojiView(color: Colors.grayVeryLight, emoji: "💰")
                    .frame(width: Sizing.image.asset, height: Sizing.image.asset)
                ListItemView(
                    title: Localized.Wallet.stake,
                    subtitle: model.stakeAprText,
                    subtitleStyle: TextStyle(font: .callout, color: Colors.green)
                )
            }
        ) {
            onSelectHeader(.stake)
        }
    }
}

// MARK: - Actions

extension AssetScene {
    private func onSelectHeader(_ buttonType: HeaderButtonType) {
        let selectType: SelectedAssetType = switch buttonType {
        case .buy: .buy(assetData.asset)
        case .send: .send(.asset(assetData.asset))
        case .swap: .swap(assetData.asset)
        case .receive: .receive(.asset)
        case .stake: .stake(assetData.asset)
        case .more:
            fatalError()
        }
        isPresentingAssetSelectedInput = SelectedAssetInput(
            type: selectType,
            assetAddress: assetData.assetAddress
        )
    }

    private func onSelectWalletHeaderInfo() {
        isPresentingInfoSheet = .watchWallet
    }

    private func onSelectOptions() {
        showingOptions = true
    }

    private func onTaskOnce() {
        Task {
            await fetch()
        }
        Task {
            await model.updateAsset()
        }
    }

    private func onBannerAction(banner: Banner) {
        let action = BannerViewModel(banner: banner).action
        switch banner.event {
        case .stake:
            onSelectHeader(.stake)
        case .activateAsset:
            onAssetActivate?(model.assetDataModel.asset)
        case .enableNotifications,
                .accountActivation,
                .accountBlockedMultiSignature:
            Task {
                try await bannerService.handleAction(action)
            }
        }
        isPresentingUrl = action.url
    }

    private func onPriceAlertToggle() {
        Task {
            if assetData.isPriceAlertsEnabled {
                isPresentingToastMessage = Localized.PriceAlerts.disabledFor(assetData.asset.name)
                await model.disablePriceAlert()
            } else {
                isPresentingToastMessage = Localized.PriceAlerts.enabledFor(assetData.asset.name)
                await model.enablePriceAlert()
            }
        }
    }
    
    private func onSelectSetPriceAlerts() {
        isPresentingSetPriceAlert = true
    }
}

// MARK: - Effects

extension AssetScene {
    private func fetch() async {
        await model.updateWallet()
    }
}

extension AssetData {
    var priceAlertSystemImage: String {
        isPriceAlertsEnabled ? SystemImage.bellFill : SystemImage.bell
    }
}
