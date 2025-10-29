// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Assets
import Transactions
import InfoSheet
import Perpetuals
import Transfer
import PriceAlerts
import PrimitivesComponents
import AssetsService
import Components
import MarketInsight

struct WalletNavigationFlowModifier: ViewModifier {
    @Environment(\.walletsService) private var walletsService
    @Environment(\.assetsService) private var assetsService
    @Environment(\.transactionsService) private var transactionsService
    @Environment(\.bannerService) private var bannerService
    @Environment(\.priceObserverService) private var priceObserverService
    @Environment(\.priceAlertService) private var priceAlertService
    @Environment(\.priceService) private var priceService
    @Environment(\.perpetualService) private var perpetualService

    let wallet: Wallet
    @Binding var isPresentingSelectedAssetInput: SelectedAssetInput?
    @Binding var isPresentingInfoSheet: InfoSheetType?
    @Binding var isPresentingSelectAssetType: SelectAssetType?
    @Binding var isPresentingTransferData: TransferData?
    @Binding var isPresentingPerpetualRecipientData: PerpetualRecipientData?
    @Binding var isPresentingSetPriceAlert: AssetId?
    @Binding var isPresentingUrl: URL?
    @Binding var isPresentingToastMessage: ToastMessage?

    let onTransferComplete: VoidAction
    let onSetPriceAlertComplete: (String) -> Void

    func body(content: Content) -> some View {
        content
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
                    onComplete: onTransferComplete
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
                    ) { onSetPriceAlertComplete($0) }
                )
            }
            .safariSheet(url: $isPresentingUrl)
            .toast(message: $isPresentingToastMessage)
    }
}

extension View {
    func walletNavigationFlow(
        wallet: Wallet,
        isPresentingSelectedAssetInput: Binding<SelectedAssetInput?>,
        isPresentingInfoSheet: Binding<InfoSheetType?>,
        isPresentingSelectAssetType: Binding<SelectAssetType?>,
        isPresentingTransferData: Binding<TransferData?>,
        isPresentingPerpetualRecipientData: Binding<PerpetualRecipientData?>,
        isPresentingSetPriceAlert: Binding<AssetId?>,
        isPresentingUrl: Binding<URL?>,
        isPresentingToastMessage: Binding<ToastMessage?>,
        onTransferComplete: VoidAction,
        onSetPriceAlertComplete: @escaping (String) -> Void
    ) -> some View {
        modifier(WalletNavigationFlowModifier(
            wallet: wallet,
            isPresentingSelectedAssetInput: isPresentingSelectedAssetInput,
            isPresentingInfoSheet: isPresentingInfoSheet,
            isPresentingSelectAssetType: isPresentingSelectAssetType,
            isPresentingTransferData: isPresentingTransferData,
            isPresentingPerpetualRecipientData: isPresentingPerpetualRecipientData,
            isPresentingSetPriceAlert: isPresentingSetPriceAlert,
            isPresentingUrl: isPresentingUrl,
            isPresentingToastMessage: isPresentingToastMessage,
            onTransferComplete: onTransferComplete,
            onSetPriceAlertComplete: onSetPriceAlertComplete
        ))
    }
}
