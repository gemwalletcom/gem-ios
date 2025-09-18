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
            if let autoAlert = model.autoAlertModel {
                Section {
                    alertView(model: autoAlert)
                } footer: {
                    Text(Localized.PriceAlerts.autoFooter)
                }
            }
            
            if model.alertsModel.isNotEmpty {
                Section {
                    ForEach(model.alertsModel, id: \.data.priceAlert.id) { alertModel in
                        alertView(model: alertModel)
                    }
                } header: {
                    Text(Localized.Stake.active)
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
                    priceAlertService: model.priceAlertService
                ) { model.onSetPriceAlertComplete(message: $0) }
            )
        }
        .toast(message: $model.isPresentingToastMessage)
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
