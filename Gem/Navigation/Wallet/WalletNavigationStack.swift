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

struct WalletNavigationStack: View {
    @Environment(\.walletsService) private var walletsService
    @Environment(\.walletService) private var walletService
    @Environment(\.navigationState) private var navigationState
    @Environment(\.priceService) private var priceService
    @Environment(\.priceAlertService) private var priceAlertService

    @Environment(\.assetsService) private var assetsService
    @Environment(\.transactionsService) private var transactionsService
    @Environment(\.bannerService) private var bannerService
    @Environment(\.priceObserverService) private var priceObserverService

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
            WalletScene(model: model)
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
                    ToolbarItem(placement: .principal) {
                        WalletBarView(
                            model: model.walletBarModel,
                            action: model.onSelectWalletBar
                        )
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: model.onSelectManage) {
                            model.manageImage
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
                            isPresentingAssetSelectedInput: $model.isPresentingAssetSelectedInput
                        )
                    )
                }
                .navigationDestination(for: TransactionExtended.self) {
                    TransactionScene(
                        input: TransactionSceneInput(
                            transactionId: $0.id,
                            walletId: model.wallet.walletId
                        )
                    )
                }
                .navigationDestination(for: Scenes.Price.self) {
                    ChartScene(
                        model: ChartsViewModel(
                            priceService: walletsService.priceService,
                            assetModel: AssetViewModel(asset: $0.asset)
                        )
                    )
                }
                .sheet(item: $model.isPresentingSelectAssetType) { value in
                    SelectAssetSceneNavigationStack(
                        model: SelectAssetViewModel(
                            wallet: model.wallet,
                            selectType: value,
                            assetsService: walletsService.assetsService,
                            walletsService: walletsService,
                            priceAlertService: priceAlertService
                        ),
                        isPresentingSelectType: $model.isPresentingSelectAssetType
                    )
                }
                .sheet(item: $model.isPresentingAssetSelectedInput) {
                    SelectedAssetNavigationStack(
                        selectType: $0,
                        wallet: model.wallet,
                        isPresentingSelectedAssetInput: $model.isPresentingAssetSelectedInput
                    )
                }
                .sheet(isPresented: $model.isPresentingWallets) {
                    WalletsNavigationStack(walletService: walletService, isPresentingWallets: $model.isPresentingWallets)
                }
                .sheet(item: $model.isPresentingInfoSheet) {
                    InfoSheetScene(model: InfoSheetViewModel(type: $0))
                }
                .safariSheet(url: $model.isPresentingUrl)
        }
    }
}
