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
            if let autoAlertModel = model.autoAlertModel {
                Section {
                    alertView(model: autoAlertModel)
                } footer: {
                    Text(Localized.PriceAlerts.autoFooter)
                }
            }
            
            Section {
                ForEach(model.alertsModel, id: \.data.priceAlert.id) { model in
                    alertView(model: model)
                }
            }
        }
        .overlay {
            if let emptyContentModel = model.emptyContentModel {
                EmptyContentView(model: emptyContentModel)
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
    
    private func alertView(model: PriceAlertItemViewModel) -> some View {
        ListAssetItemView(model: model)
            .swipeActions(edge: .trailing) {
                Button(Localized.Common.delete, role: .destructive) {
                    onDelete(alert: model.data.priceAlert)
                }
                .tint(Colors.red)
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
