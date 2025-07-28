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

struct WalletNavigationStack: View {
    @Environment(\.walletsService) private var walletsService
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
                            isPresentingSelectedAssetInput: model.isPresentingSelectedAssetInput
                        )
                    )
                }
                .navigationDestination(for: TransactionExtended.self) {
                    TransactionScene(
                        model: TransactionDetailViewModel(
                            transaction: $0,
                            walletId: model.wallet.id
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
                .navigationDestination(for: Scenes.Perpetuals.self) { _ in
                    PerpetualsNavigationView(
                        wallet: model.wallet,
                        perpetualService: AppResolver.main.services.perpetualService,
                        isPresentingSelectAssetType: $model.isPresentingSheet.selectAssetType,
                        isPresentingTransferData: $model.isPresentingSheet.transferData
                    )
                }
                .navigationDestination(for: Scenes.Perpetual.self) { scene in
                    PerpetualNavigationView(
                        perpetualData: scene.perpetualData,
                        wallet: model.wallet,
                        perpetualService: AppResolver.main.services.perpetualService,
                        isPresentingTransferData: $model.isPresentingSheet.transferData,
                        isPresentingPerpetualRecipientData: $model.isPresentingSheet.perpetualRecipientData
                    )
                }
                .sheet(item: $model.isPresentingSheet) { sheet in
                    switch sheet {
                    case let .selectAssetType(value):
                        SelectAssetSceneNavigationStack(
                            model: SelectAssetViewModel(
                                wallet: model.wallet,
                                selectType: value,
                                assetsService: walletsService.assetsService,
                                walletsService: walletsService,
                                priceAlertService: priceAlertService
                            ),
                            isPresentingSelectType: $model.isPresentingSheet.selectAssetType
                        )
                    case let .info(type):
                        InfoSheetScene(model: InfoSheetViewModel(type: type))
                    case let .perpetualRecipientData(perpetualRecipientData):
                        AmountNavigationStack(
                            model: AmountSceneViewModel(
                                input: AmountInput(
                                    type: .perpetual(recipient: perpetualRecipientData.recipientData, perpetualRecipientData.direction),
                                    asset: perpetualRecipientData.asset
                                ),
                                wallet: model.wallet,
                                walletsService: walletsService,
                                stakeService: AppResolver.main.services.stakeService,
                                onTransferAction: { transferData in
                                    model.isPresentingSheet = .transferData(transferData)
                                }
                            )
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
        }
    }
}
