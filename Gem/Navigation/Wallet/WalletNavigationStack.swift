// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import PrimitivesComponents
import Store
import MarketInsight
import Transactions
import WalletTab
import InfoSheet
import Components
import Assets
import Perpetuals
import Transfer
import StakeService
import PriceAlerts
import AssetsService

struct WalletNavigationStack: View {
    @Environment(\.walletsService) private var walletsService
    @Environment(\.navigationState) private var navigationState
    @Environment(\.priceService) private var priceService
    @Environment(\.priceAlertService) private var priceAlertService
    @Environment(\.assetsService) private var assetsService
    @Environment(\.transactionsService) private var transactionsService
    @Environment(\.bannerService) private var bannerService
    @Environment(\.priceObserverService) private var priceObserverService
    @Environment(\.perpetualService) private var perpetualService
    @Environment(\.hyperliquidObserverService) private var hyperliquidObserverService
    @Environment(\.activityService) private var activityService
    @Environment(\.walletSearchService) private var walletSearchService
    @Environment(\.assetSearchService) private var assetSearchService
    @Environment(\.observablePreferences) private var preferences

    @State private var model: WalletSceneViewModel

    init(model: WalletSceneViewModel) {
        _model = State(initialValue: model)
    }

    private var navigationPath: Binding<NavigationPath> {
        Binding(
            get: { navigationState.wallet },
            set: { navigationState.wallet = $0 }
        )
    }

    var body: some View {
        NavigationStack(path: navigationPath) {
            ZStack {
                WalletScene(model: model)
                    .opacity(model.isPresentingSearch ? 0 : 1)

                if model.isPresentingSearch {
                    WalletSearchScene(
                        model: WalletSearchSceneViewModel(
                            wallet: model.wallet,
                            searchService: walletSearchService,
                            activityService: activityService,
                            walletsService: walletsService,
                            perpetualService: perpetualService,
                            onDismissSearch: model.onToggleSearch,
                            onSelectAssetAction: onSelectAsset,
                            onAddToken: model.onSelectAddCustomToken
                        )
                    )
                    .transition(.opacity)
                }
            }
            .onChange(of: model.currentWallet, model.onChangeWallet)
            .onChange(of: navigationState.walletTabReselected, model.onWalletTabReselected)
            .observeQuery(
                request: $model.assetsRequest,
                value: $model.assets
            )
            .observeQuery(
                request: $model.bannersRequest,
                value: $model.banners
            )
            .observeQuery(
                request: $model.totalFiatRequest,
                value: $model.totalFiatValue
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !model.isPresentingSearch {
                    ToolbarItem(placement: .principal) {
                        WalletBarView(
                            model: model.walletBarModel,
                            action: model.onSelectWalletBar
                        )
                        .liquidGlass()
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: model.onToggleSearch) {
                            model.searchImage
                        }
                    }
                }
            }
            .navigationDestination(for: Scenes.Asset.self) {
                AssetNavigationView(
                    model: AssetSceneViewModel(
                        walletsService: walletsService,
                        assetsService: assetsService,
                        transactionsService: transactionsService,
                        priceObserverService: priceObserverService,
                        priceAlertService: priceAlertService,
                        bannerService: bannerService,
                        input: AssetSceneInput(
                            wallet: model.wallet,
                            asset: $0.asset
                        ),
                        isPresentingSelectedAssetInput: model.isPresentingSelectedAssetInput
                    )
                )
            }
            .navigationDestination(for: TransactionExtended.self) {
                TransactionNavigationView(
                    model: TransactionSceneViewModel(
                        transaction: $0,
                        walletId: model.wallet.walletId
                    )
                )
            }
            .navigationDestination(for: Scenes.Price.self) {
                ChartScene(
                    model: ChartSceneViewModel(
                        priceService: priceService,
                        assetModel: AssetViewModel(asset: $0.asset),
                        priceAlertService: priceAlertService,
                        walletId: model.wallet.walletId,
                        isPresentingSetPriceAlert: $model.isPresentingSetPriceAlert
                    )
                )
            }
            .navigationDestination(for: Scenes.Perpetuals.self) { _ in
                PerpetualsNavigationView(
                    wallet: model.wallet,
                    perpetualService: perpetualService,
                    observerService: hyperliquidObserverService,
                    activityService: activityService,
                    onSelectAssetType: { model.isPresentingSelectAssetType = $0 },
                    onSelectAsset: { navigationState.wallet.append(Scenes.Perpetual($0)) }
                )
            }
            .navigationDestination(for: Scenes.AssetsResults.self) { destination in
                AssetsResultsScene(
                    model: AssetsResultsSceneViewModel(
                        wallet: model.wallet,
                        walletsService: walletsService,
                        preferences: preferences.preferences,
                        request: WalletSearchRequest(
                            walletId: model.wallet.walletId,
                            searchBy: destination.searchQuery,
                            tag: destination.tag,
                            limit: AssetsResultsSceneViewModel.defaultLimit
                        ),
                        onSelectAsset: onSelectAsset
                    )
                )
            }
            .navigationDestination(for: Scenes.Perpetual.self) {
                PerpetualNavigationView(
                    asset: $0.asset,
                    wallet: model.wallet,
                    perpetualService: perpetualService,
                    observerService: hyperliquidObserverService,
                    isPresentingTransferData: $model.isPresentingTransferData,
                    isPresentingPerpetualRecipientData: $model.isPresentingPerpetualRecipientData
                )
            }
            .navigationDestination(for: Scenes.AssetPriceAlert.self) {
                AssetPriceAlertsScene(
                    model: AssetPriceAlertsViewModel(
                        priceAlertService: priceAlertService,
                        walletId: model.wallet.walletId,
                        asset: $0.asset
                    )
                )
            }
            .sheet(item: $model.isPresentingSelectAssetType) {
                SelectAssetSceneNavigationStack(
                    model: SelectAssetViewModel(
                        wallet: model.wallet,
                        selectType: $0,
                        searchService: assetSearchService,
                        walletsService: walletsService,
                        priceAlertService: priceAlertService,
                        activityService: activityService
                    ),
                    isPresentingSelectType: $model.isPresentingSelectAssetType
                )
            }
            .sheet(isPresented: $model.isPresentingWallets) {
                WalletsNavigationStack(isPresentingWallets: $model.isPresentingWallets)
            }
            .sheet(item: $model.isPresentingInfoSheet) {
                InfoSheetScene(type: $0)
            }
            .sheet(item: $model.isPresentingTransferData) {
                ConfirmTransferNavigationStack(
                    wallet: model.wallet,
                    transferData: $0,
                    onComplete: model.onTransferComplete
                )
            }
            .sheet(item: $model.isPresentingPerpetualRecipientData) {
                PerpetualPositionNavigationStack(
                    perpetualRecipientData: $0,
                    wallet: model.wallet,
                    onComplete: {
                        model.isPresentingPerpetualRecipientData = nil
                    }
                )
            }
            .sheet(item: $model.isPresentingSetPriceAlert) { assetId in
                SetPriceAlertNavigationStack(
                    model: SetPriceAlertViewModel(
                        walletId: model.wallet.walletId,
                        assetId: assetId,
                        priceAlertService: priceAlertService
                    ) { model.onSetPriceAlertComplete(message: $0) }
                )
            }
            .sheet(isPresented: $model.isPresentingAddToken) {
                AddTokenNavigationStack(
                    wallet: model.wallet,
                    isPresenting: $model.isPresentingAddToken
                )
            }
            .safariSheet(url: $model.isPresentingUrl)
            .toast(message: $model.isPresentingToastMessage)
        }
    }

    private func onSelectAsset(asset: Asset) {
        if asset.type == .perpetual {
            navigationState.wallet.append(Scenes.Perpetual(asset))
        } else {
            navigationState.wallet.append(Scenes.Asset(asset: asset))
        }
    }
}
