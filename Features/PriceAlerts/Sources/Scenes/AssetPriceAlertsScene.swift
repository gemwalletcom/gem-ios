// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Store
import Primitives
import Style
import Components
import Localization
import PrimitivesComponents

public struct AssetPriceAlertsScene: View {
    @State private var model: AssetPriceAlertsViewModel

    public init(model: AssetPriceAlertsViewModel) {
        _model = State(initialValue: model)
    }
    
    public var body: some View {
        List {
            ForEach(model.alertsModel, id: \.data.priceAlert.id) { alert in
                ListAssetItemView(model: alert)
                    .swipeActions(edge: .trailing) {
                        Button(Localized.Common.delete, role: .destructive) {
                            onDelete(alert: alert.data.priceAlert)
                        }
                        .tint(Colors.red)
                    }
            }
        }
        .observeQuery(request: $model.request, value: $model.priceAlerts)
        .listSectionSpacing(.compact)
        .refreshable { await model.fetch() }
        .task { await model.fetch() }
        .navigationTitle(model.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: model.onSelectSetPriceAlert) {
                    Image(systemName: SystemImage.plus)
                }
            }
        }
        .sheet(isPresented: $model.isPresentingSetPriceAlert) {
            SetPriceAlertNavigationStack(
                model: SetPriceAlertViewModel(
                    walletId: model.walletId,
                    assetId: model.asset.id,
                    priceAlertService: model.priceAlertService,
                    onComplete: { _ in
                        model.onSetPriceAlertComplete()
                    }
                )
            )
        }
    }
}

// MARK: - Actions

extension AssetPriceAlertsScene {
    func onDelete(alert: PriceAlert) {
        Task {
            await model.deletePriceAlert(priceAlert: alert)
        }
    }
}
