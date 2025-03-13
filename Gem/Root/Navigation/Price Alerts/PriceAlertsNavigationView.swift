// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import PriceAlerts

struct PriceAlertsNavigationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.keystore) private var keystore
    @Environment(\.assetsService) private var assetsService
    @Environment(\.walletsService) private var walletsService
    @Environment(\.priceService) private var priceService
    @Environment(\.priceAlertService) private var priceAlertService

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
        .onChange(of: isPresentingAddAsset) { _, _ in
            Task {
                await model.fetch()
            }
        }
        .sheet(isPresented: $isPresentingAddAsset) {
            AddAssetPriceAlertsNavigationStack(
                model: AddAssetPriceAlertsViewModel(
                    priceAlertService: priceAlertService
                ),
                selectAssetModel: SelectAssetViewModel(
                    wallet: keystore.currentWallet!,
                    keystore: keystore,
                    selectType: .priceAlert,
                    assetsService: assetsService,
                    walletsService: walletsService,
                    priceAlertService: priceAlertService
                )
            )
        }
    }
}
