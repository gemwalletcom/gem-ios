// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import GRDB
import GRDBQuery
import Store
import Primitives
import Style
import Components
import Localization

public struct PriceAlertsScene: View {
    @State private var model: PriceAlertsViewModel

    @Query<PriceAlertsRequest>
    private var priceAlerts: [PriceAlertData]

    public init(model: PriceAlertsViewModel) {
        _model = State(initialValue: model)
        _priceAlerts = Query(constant: model.request)
    }

    public var body: some View {
        List {
            Section {
                Toggle(
                    model.enableTitle,
                    isOn: $model.isPriceAlertsEnabled
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
                                    Button(Localized.Common.delete, role: .destructive) {
                                        onDelete(alert: alert)
                                    }
                                    .tint(Colors.red)
                                }
                        }
                    }
                }
            }
        }
        .onChange(of: model.isPriceAlertsEnabled, onAlertsEnable)
        .refreshable {
            await model.fetch()
        }
        .task {
            await model.fetch()
        }
        .navigationTitle(model.title)
    }
}

// MARK: - Actions

extension PriceAlertsScene {
    func onDelete(alert: PriceAlertData) {
        Task {
            await model.deletePriceAlert(assetId: alert.asset.id)
        }
    }

    func onAlertsEnable(_ _: Bool, newValue: Bool) {
        Task {
            await model.handleAlertsEnabled(enabled: newValue)
        }
    }
}
