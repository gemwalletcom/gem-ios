// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import GRDB
import GRDBQuery
import Store
import Style
import Localization

struct AssetScene: View {
    @Environment(\.walletsService) private var walletsService
    @Environment(\.assetsService) private var assetsService
    @Environment(\.transactionsService) private var transactionsService
    @Environment(\.stakeService) private var stakeService
    @Environment(\.bannerService) private var bannerService
    @Environment(\.priceAlertService) private var priceAlertService

    @State private var showingOptions = false
    @State private var showingPriceAlertMessage = false

    @Binding private var isPresentingAssetSelectType: SelectAssetInput?

    @Query<TransactionsRequest>
    private var transactions: [TransactionExtended]

    @Query<AssetRequest>
    private var assetData: AssetData

    @Query<BannersRequest>
    private var banners: [Primitives.Banner]


    private let wallet: Wallet
    private let input: AssetSceneInput

    private var model: AssetSceneViewModel {
        return AssetSceneViewModel(
            walletsService: walletsService,
            assetsService: assetsService,
            transactionsService: transactionsService,
            stakeService: stakeService,
            priceAlertService: priceAlertService,
            assetDataModel: AssetDataViewModel(assetData: assetData, formatter: .medium),
            walletModel: WalletViewModel(wallet: wallet)
        )
    }

    init(
        wallet: Wallet,
        input: AssetSceneInput,
        isPresentingAssetSelectType: Binding<SelectAssetInput?>
    ) {
        self.wallet = wallet
        self.input = input
        _isPresentingAssetSelectType = isPresentingAssetSelectType
        _assetData = Query(constant: input.assetRequest)
        _transactions = Query(constant: input.transactionsRequest)
        _banners = Query(constant: input.bannersRequest)
    }

    var body: some View {
        List {
            Section { } header: {
                WalletHeaderView(model: model.headerViewModel, action: onSelectHeader(_:))
                    .padding(.top, Spacing.small)
                    .padding(.bottom, Spacing.medium)
            }
            .frame(maxWidth: .infinity)
            .textCase(nil)
            .listRowSeparator(.hidden)
            .listRowInsets(.zero)

            Section {
                BannerView(banners: banners, action: onBannerAction, closeAction: bannerService.onClose)
            }

            Section {
                if model.showPriceView {
                    NavigationLink(value: Scenes.Price(asset: model.assetModel.asset)) {
                        HStack {
                            ListItemView(title: Localized.Asset.price)
                                .accessibilityIdentifier("price")
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

            if transactions.count > 0 {
                TransactionsList(transactions)
            } else {
                Section {
                    StateEmptyView(title: Localized.Activity.EmptyState.message)
                }
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
                        Image(systemName: SystemImage.ellipsis)
                    }
                    .confirmationDialog("", isPresented: $showingOptions, titleVisibility: .hidden) {
                        Button(model.viewAddressOnTitle) { onOpenLink(model.addressExplorerUrl )}
                        if let title = model.viewTokenOnTitle, let url = model.tokenExplorerUrl {
                            Button(title) { onOpenLink(url) }
                        }
                    }
                }
            }
        }
        .taskOnce(onTaskOnce)
        .listSectionSpacing(.compact)
        .navigationTitle(model.title)
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
//        NavigationLink(value: Scenes.Stake(chain: model.assetModel.asset.chain, wallet: wallet)) {
//
//        }
        NavigationCustomLink(with: ListItemView(title: Localized.Wallet.stake, subtitle: model.assetDataModel.stakeBalanceTextWithSymbol)
            .accessibilityIdentifier("stake")) {
                isPresentingAssetSelectType = SelectAssetInput(type: .stake, assetAddress: assetData.assetAddress)
            }
    }
}

// MARK: - Actions

extension AssetScene {
    @MainActor
    private func onSelectHeader(_ buttonType: HeaderButtonType) {
        isPresentingAssetSelectType = SelectAssetInput(type: buttonType.selectType, assetAddress: assetData.assetAddress)
    }

    @MainActor
    private func onOpenLink(_ url: URL) {
        UIApplication.shared.open(url)
    }

    @MainActor
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
        switch banner.event {
        case .stake:
            isPresentingAssetSelectType = SelectAssetInput(type: .stake, assetAddress: assetData.assetAddress)
        case .enableNotifications:
            break
        case .accountActivation:
            if let url = model.reservedBalanceUrl {
                onOpenLink(url)
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
