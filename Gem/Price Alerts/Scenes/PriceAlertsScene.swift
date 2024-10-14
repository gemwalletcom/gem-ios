// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import GRDB
import GRDBQuery
import Store
import Primitives
import Style
import Components
import Localization

struct PriceAlertsScene: View {

    let model: PriceAlertsViewModel

    @State private var isPriceAlertsEnabled: Bool

    @Query<PriceAlertsRequest>
    var priceAlerts: [PriceAlertData]

    init(
        model: PriceAlertsViewModel
    ) {
        self.model = model
        _priceAlerts = Query(constant: model.request)
        _isPriceAlertsEnabled = State(initialValue: model.isPriceAlertsEnabled)
    }

    var body: some View {
        List {
            Section {
                Toggle(
                    model.enableTitle,
                    isOn: $isPriceAlertsEnabled
                )
                .toggleStyle(AppToggleStyle())
            } footer: {
                Text(Localized.PriceAlerts.getNotifiedExplainMessage)
            }

            Section {
                if priceAlerts.isEmpty {
                    StateEmptyView(title: Localized.PriceAlerts.EmptyState.message)
                } else {
                    ForEach(priceAlerts) { alert in
                        NavigationLink(value: Scenes.Price(asset: alert.asset)) {
                            ListAssetItemView(model: PriceAlertItemViewModel(data: alert))
                                .swipeActions(edge: .trailing) {
                                    Button(Localized.Common.delete) {
                                        onDelete(alert: alert)
                                    }
                                    .tint(Colors.red)
                                }
                        }
                    }
                }
            }
        }
        .refreshable {
            await model.fetch()
        }
        .onChange(of: isPriceAlertsEnabled) { (_, newValue) in
            Task {
                await model.onPriceAlertsEnabled(newValue: newValue)
            }
        }
        .task {
            await model.fetch()
        }
        .navigationTitle(model.title)
    }
}

#Preview {
    PriceAlertsScene(
        model: PriceAlertsViewModel(priceAlertService: .main, priceService: .main)
    )
}

// MARK: - Actions

extension PriceAlertsScene {
    func onDelete(alert: PriceAlertData) {
        Task {
            await model.deletePriceAlert(assetId: alert.asset.id)
        }
    }
}
