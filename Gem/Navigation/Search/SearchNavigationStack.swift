// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import WalletTab
import AssetsService
import Assets
import Transactions
import InfoSheet
import Components
import Perpetuals
import Transfer
import StakeService
import PriceAlerts
import MarketInsight
import PrimitivesComponents
import Style

struct SearchNavigationStack: View {
    @Environment(\.navigationState) private var navigationState
    @Environment(\.walletsService) private var walletsService
    @Environment(\.assetsService) private var assetsService
    @Environment(\.transactionsService) private var transactionsService
    @Environment(\.bannerService) private var bannerService
    @Environment(\.priceObserverService) private var priceObserverService
    @Environment(\.priceAlertService) private var priceAlertService
    @Environment(\.priceService) private var priceService
    @Environment(\.perpetualService) private var perpetualService

    private let wallet: Wallet
    @Binding private var isPresentingSelectedAssetInput: SelectedAssetInput?

    @State private var isPresentingInfoSheet: InfoSheetType?
    @State private var isPresentingSelectAssetType: SelectAssetType?
    @State private var isPresentingTransferData: TransferData?
    @State private var isPresentingPerpetualRecipientData: PerpetualRecipientData?
    @State private var isPresentingSetPriceAlert: AssetId?
    @State private var isPresentingUrl: URL?
    @State private var isPresentingToastMessage: ToastMessage?

    init(
        wallet: Wallet,
        isPresentingSelectedAssetInput: Binding<SelectedAssetInput?>
    ) {
        self.wallet = wallet
        _isPresentingSelectedAssetInput = isPresentingSelectedAssetInput
    }

    private var navigationPath: Binding<NavigationPath> {
        Binding(
            get: { navigationState.search },
            set: { navigationState.search = $0 }
        )
    }

    var body: some View {
        NavigationStack(path: navigationPath) {
            WalletSearchScene(
                model: WalletSearchSceneViewModel(
                    wallet: wallet,
                    searchService: AssetSearchService(assetsService: assetsService),
                )
            )
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
                            wallet: wallet,
                            asset: $0.asset
                        ),
                        isPresentingSelectedAssetInput: $isPresentingSelectedAssetInput
                    )
                )
            }
            .navigationDestination(for: TransactionExtended.self) {
                TransactionNavigationView(
                    model: TransactionSceneViewModel(
                        transaction: $0,
                        walletId: wallet.id
                    )
                )
            }
            .navigationDestination(for: Scenes.Price.self) {
                ChartScene(
                    model: ChartsViewModel(
                        priceService: priceService,
                        assetModel: AssetViewModel(asset: $0.asset),
                        priceAlertService: priceAlertService,
                        walletId: wallet.walletId,
                        isPresentingSetPriceAlert: $isPresentingSetPriceAlert
                    )
                )
            }
            .navigationDestination(for: Scenes.Perpetuals.self) { _ in
                PerpetualsNavigationView(
                    wallet: wallet,
                    perpetualService: perpetualService,
                    isPresentingSelectAssetType: $isPresentingSelectAssetType
                )
            }
            .navigationDestination(for: Scenes.Perpetual.self) {
                PerpetualNavigationView(
                    perpetualData: $0.perpetualData,
                    wallet: wallet,
                    perpetualService: perpetualService,
                    isPresentingTransferData: $isPresentingTransferData,
                    isPresentingPerpetualRecipientData: $isPresentingPerpetualRecipientData
                )
            }
            .navigationDestination(for: Scenes.AssetPriceAlert.self) {
                AssetPriceAlertsScene(
                    model: AssetPriceAlertsViewModel(
                        priceAlertService: priceAlertService,
                        walletId: wallet.walletId,
                        asset: $0.asset
                    )
                )
            }
            .sheet(item: $isPresentingSelectAssetType) {
                SelectAssetSceneNavigationStack(
                    model: SelectAssetViewModel(
                        wallet: wallet,
                        selectType: $0,
                        searchService: AssetSearchService(assetsService: assetsService),
                        walletsService: walletsService,
                        priceAlertService: priceAlertService
                    ),
                    isPresentingSelectType: $isPresentingSelectAssetType
                )
            }
            .sheet(item: $isPresentingInfoSheet) {
                InfoSheetScene(type: $0)
            }
            .sheet(item: $isPresentingTransferData) {
                ConfirmTransferNavigationStack(
                    wallet: wallet,
                    transferData: $0,
                    onComplete: {}
                )
            }
            .sheet(item: $isPresentingPerpetualRecipientData) {
                PerpetualPositionNavigationStack(
                    perpetualRecipientData: $0,
                    wallet: wallet,
                    onComplete: {
                        isPresentingPerpetualRecipientData = nil
                    }
                )
            }
            .sheet(item: $isPresentingSetPriceAlert) { assetId in
                SetPriceAlertNavigationStack(
                    model: SetPriceAlertViewModel(
                        walletId: wallet.walletId,
                        assetId: assetId,
                        priceAlertService: priceAlertService
                    ) { message in
                        isPresentingToastMessage = ToastMessage(title: message, image: SystemImage.bellFill)
                    }
                )
            }
            .safariSheet(url: $isPresentingUrl)
            .toast(message: $isPresentingToastMessage)
        }
    }
}
