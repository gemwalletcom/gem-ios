// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Localization
import Store
import Components
import InfoSheet
import PriceAlerts
import Assets

struct AssetNavigationView: View {
    @State private var model: AssetSceneViewModel

    init(model: AssetSceneViewModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        AssetScene(
            model: model
        )
        .observeQuery(request: $model.input.assetRequest, value: $model.assetData)
        .observeQuery(request: $model.input.bannersRequest, value: $model.banners)
        .observeQuery(request: $model.input.transactionsRequest, value: $model.transactions)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    if model.isDeveloperEnabled {
                        Button(action: model.onSelectSetPriceAlerts) {
                            model.addImage
                        }
                    }
                    Button(action: model.onTogglePriceAlert) {
                        model.priceAlertsImage
                    }
                    Button(action: model.onSelectOptions) {
                        model.optionsImage
                    }
                }
            }
        }
        .toast(
            message: $model.isPresentingToastMessage,
            systemImage: model.priceAlertsSystemImage
        )
        .confirmationDialog(
            model.title,
            presenting: $model.isPresentingOptions,
            actions: { _ in
                Button(model.viewAddressOnTitle) {
                    model.onSelect(url: model.addressExplorerUrl)
                }
                if let title = model.viewTokenOnTitle {
                    Button(title) {
                        model.onSelect(url: model.tokenExplorerUrl)
                    }
                }
                Button(Localized.Common.share) {
                    model.onSelectShareAsset()
                }
            }
        )
        .sheet(item: $model.isPresentingAssetSheet) {
            switch $0 {
            case let .info(type):
                InfoSheetScene(model: InfoSheetViewModel(type: type))
            case let .transfer(data):
                ConfirmTransferNavigationStack(
                    wallet: model.walletModel.wallet,
                    transferData: data,
                    onComplete: model.onTransferComplete
                )
            case .setPriceAlert:
                SetPriceAlertNavigationStack(
                    model: SetPriceAlertViewModel(
                        wallet: model.walletModel.wallet,
                        assetId: model.assetModel.asset.id,
                        priceAlertService: model.priceAlertService,
                        onComplete: model.onSetPriceAlertComplete(message:)
                    )
                )
            case .share:
                ShareSheet(activityItems: [model.shareAssetUrl.absoluteString])
            case let .url(url):
                SFSafariView(url: url)
            }
        }
    }
}
