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
import PrimitivesComponents

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
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: model.onTogglePriceAlert) {
                    model.priceAlertsImage
                }

                AdaptiveActionMenu(
                    title: model.title,
                    items: model.menuItems,
                    label: { model.optionsImage }
                )
            }
        }
        .toast(message: $model.isPresentingToastMessage)
        .sheet(item: $model.isPresentingAssetSheet) {
            switch $0 {
            case let .info(type):
                InfoSheetScene(type: type)
            case let .transfer(data):
                ConfirmTransferNavigationStack(
                    wallet: model.walletModel.wallet,
                    transferData: data,
                    onComplete: model.onTransferComplete
                )
            case .share:
                ShareSheet(activityItems: [model.shareAssetUrl.absoluteString])
            case let .url(url):
                SFSafariView(url: url)
            }
        }
    }
}
