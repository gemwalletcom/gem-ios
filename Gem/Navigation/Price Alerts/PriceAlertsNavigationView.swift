// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import PriceAlerts
import Assets
import Localization
import Primitives
import Components
import AssetsService

struct PriceAlertsNavigationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.walletsService) private var walletsService
    @Environment(\.priceService) private var priceService
    @Environment(\.priceAlertService) private var priceAlertService
    @Environment(\.walletService) private var walletService
    @Environment(\.activityService) private var activityService
    @Environment(\.assetSearchService) private var assetSearchService

    @State private var isPresentingAddAsset: Bool = false
    @State private var isPresentingToastMessage: ToastMessage?

    let model: PriceAlertsSceneViewModel

    var body: some View {
        PriceAlertsScene(model: model)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isPresentingAddAsset = true
                } label: {
                    Images.System.plus
                }
            }
        }
        .sheet(isPresented: $isPresentingAddAsset) {
            AddAssetPriceAlertsNavigationStack(
                selectAssetModel: SelectAssetViewModel(
                    wallet: walletService.currentWallet!,
                    selectType: .priceAlert,
                    searchService: assetSearchService,
                    walletsService: walletsService,
                    priceAlertService: priceAlertService,
                    activityService: activityService,
                    selectAssetAction: onSelectAsset
                )
            )
        }
        .toast(message: $isPresentingToastMessage)
    }
    
    private func onSelectAsset(asset: Asset) {
        isPresentingAddAsset = false
        isPresentingToastMessage = .priceAlert(for: asset.name, enabled: true)
    }
}
