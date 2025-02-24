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

struct AssetScene: View {
    @Environment(\.walletsService) private var walletsService
    @Environment(\.assetsService) private var assetsService
    @Environment(\.transactionsService) private var transactionsService
    @Environment(\.bannerService) private var bannerService
    @Environment(\.priceAlertService) private var priceAlertService

    @State private var showingOptions = false
    @State private var showingPriceAlertMessage = false
    @State private var isPresentingShareAssetSheet = false
    @State private var isPresentingInfoSheet: InfoSheetType? = .none

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
            bannersViewModel: HeaderBannersViewModel(banners: model.banners + banners)
        )
    }
    
    private var model: AssetSceneViewModel {
        return AssetSceneViewModel(
            walletsService: walletsService,
            assetsService: assetsService,
            transactionsService: transactionsService,
            priceAlertService: priceAlertService,
            assetDataModel: AssetDataViewModel(
                assetData: assetData,
                formatter: .medium,
                currencyCode: Preferences.standard.currency
            ),
            walletModel: walletModel
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
                    .padding(.top, Spacing.small)
                    .padding(.bottom, Spacing.medium)
            }
            .cleanListRow()

            Section {
                BannerView(banners: model.banners, action: onBannerAction, closeAction: bannerService.onClose)
            }
                        
            Section {
                NavigationLink(value: Scenes.Price(asset: model.assetModel.asset)) {
                    HStack {
                        ListItemView(title: Localized.Asset.price)
                            .accessibilityIdentifier("price")

                        if model.showPriceView {
                            Spacer()
                            HStack(spacing: Spacing.tiny) {
                                Text(model.priceView.text)
                                    .textStyle(model.priceView.style)
                                Text(model.priceChangeView.text)
                                    .textStyle(model.priceChangeView.style)
                            }
                        }
                    }
                }
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
                        NavigationCustomLink(
                            with: ListItemView(title: Localized.Asset.Balances.reserved, subtitle: model.assetDataModel.reservedBalanceTextWithSymbol),
                            action: { onOpenLink(url) }
                        )
                    }
                }
            } else if model.assetDataModel.isStakeEnabled {
                stakeView
            }

            if !transactions.isEmpty {
                TransactionsList(
                    explorerService: model.explorerService,
                    transactions
                )
            } else {
                EmptyContentView(model: model.emptyConentModel)
                    .cleanListRow(topOffset: Spacing.extraLarge)
            }
        }
        .refreshable {
            await fetch()
        }
        .modifier(
            ToastModifier(
                isPresenting: $showingPriceAlertMessage,
                value: assetData.isPriceAlertsEnabled ? Localized.PriceAlerts.enabledFor(assetData.asset.name) : Localized.PriceAlerts.disabledFor(assetData.asset.name),
                systemImage: assetData.priceAlertSystemImage
            )
        )
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: onPriceAlertToggle) {
                        Image(systemName: assetData.priceAlertSystemImage)
                    }
                    Button(action: onSelectOptions) {
                        Images.System.ellipsis
                    }
                    .confirmationDialog("", isPresented: $showingOptions, titleVisibility: .hidden) {
                        Button(model.viewAddressOnTitle) { onOpenLink(model.addressExplorerUrl )}
                        if let title = model.viewTokenOnTitle, let url = model.tokenExplorerUrl {
                            Button(title) { onOpenLink(url) }
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
    }
}

// MARK: - UI Components

extension AssetScene {
    private var networkView: some View {
        HStack {
            ListItemView(title: model.networkField, subtitle: model.networkText)
            AssetImageView(assetImage: model.networkAssetImage, size: Sizing.list.image)
        }
    }

    private var stakeView: some View {
        NavigationCustomLink(with: ListItemView(title: Localized.Wallet.stake, subtitle: model.assetDataModel.stakeBalanceTextWithSymbol)
            .accessibilityIdentifier("stake")) {
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

    private func onOpenLink(_ url: URL) {
        UIApplication.shared.open(url)
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
    }

    private func onPriceAlertToggle() {
        showingPriceAlertMessage = true

        Task {
            if assetData.isPriceAlertsEnabled {
                await model.disablePriceAlert()
            } else {
                await model.enablePriceAlert()
            }
        }
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
