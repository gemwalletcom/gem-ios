// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import PriceAlerts
import Assets

struct PriceAlertsNavigationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.assetsService) private var assetsService
    @Environment(\.walletsService) private var walletsService
    @Environment(\.priceService) private var priceService
    @Environment(\.priceAlertService) private var priceAlertService
    @Environment(\.walletService) private var walletService

    @State private var isPresentingAddAsset: Bool = false
    @State private var assetPriceAlertsNavigationPath = NavigationPath()

    let model: PriceAlertsViewModel

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
                model: AddAssetPriceAlertsViewModel(
                    priceAlertService: priceAlertService
                ),
                selectAssetModel: SelectAssetViewModel(
                    wallet: walletService.currentWallet!,
                    selectType: .priceAlert,
                    assetsService: assetsService,
                    walletsService: walletsService,
                    priceAlertService: priceAlertService
                )
            )
        }
    }
}
