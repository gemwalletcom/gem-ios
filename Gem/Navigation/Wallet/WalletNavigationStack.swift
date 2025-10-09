// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import PrimitivesComponents
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
    @Environment(\.stakeService) private var stakeService
    @Environment(\.perpetualService) private var perpetualService
    @Environment(\.balanceService) private var balanceService

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
                            searchService: AssetSearchService(assetsService: assetsService),
                            onDismissSearch: model.onToggleSearch
                        )
                    )
                    .transition(.opacity)
                }
            }
            .onChange(of: model.currentWallet, model.onChangeWallet)
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
                        walletId: model.wallet.id
                    )
                )
            }
            .navigationDestination(for: Scenes.Price.self) {
                ChartScene(
                    model: ChartsViewModel(
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
                    isPresentingSelectAssetType: $model.isPresentingSheet.selectAssetType
                )
            }
            .navigationDestination(for: Scenes.Perpetual.self) { scene in
                PerpetualNavigationView(
                    perpetualData: scene.perpetualData,
                    wallet: model.wallet,
                    perpetualService: perpetualService,
                    isPresentingTransferData: $model.isPresentingSheet.transferData,
                    isPresentingPerpetualRecipientData: $model.isPresentingSheet.perpetualRecipientData
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
            .sheet(item: $model.isPresentingSheet) { sheet in
                switch sheet {
                case let .selectAssetType(value):
                    SelectAssetSceneNavigationStack(
                        model: SelectAssetViewModel(
                            wallet: model.wallet,
                            selectType: value,
                            searchService: AssetSearchService(assetsService: assetsService),
                            walletsService: walletsService,
                            priceAlertService: priceAlertService
                        ),
                        isPresentingSelectType: $model.isPresentingSheet.selectAssetType
                    )
                case let .info(type):
                    InfoSheetScene(type: type)
                case let .perpetualRecipientData(perpetualRecipientData):
                    PerpetualPositionNavigationStack(
                        perpetualRecipientData: perpetualRecipientData,
                        wallet: model.wallet,
                        onComplete: {
                            model.isPresentingSheet = nil
                        }
                    )
                case let .transferData(transferData):
                    ConfirmTransferNavigationStack(
                        wallet: model.wallet,
                        transferData: transferData,
                        onComplete: model.onTransferComplete
                    )
                case let .url(url):
                    SFSafariView(url: url)
                case .wallets:
                    WalletsNavigationStack(isPresentingWallets: $model.isPresentingSheet.wallets)
                }
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
            .toast(message: $model.isPresentingToastMessage)
        }
    }
}
