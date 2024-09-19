// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

struct PriceAlertsNavigationView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.priceService) private var priceService
    @Environment(\.priceAlertService) private var priceAlertService

    @State private var isPresentingAddAsset: Bool = false

    let model: PriceAlertsViewModel

    var body: some View {
        PriceAlertsScene(model: model)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isPresentingAddAsset = true
                } label: {
                    Image(systemName: SystemImage.plus)
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
                model: AddAssetPriceAlertsViewModel(priceAlertService: priceAlertService)
            )
        }
    }
}
