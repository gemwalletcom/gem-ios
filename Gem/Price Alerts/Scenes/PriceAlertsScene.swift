// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import GRDB
import GRDBQuery
import Store
import Primitives
import Style
import Components

struct PriceAlertsScene: View {

    let model: PriceAlertsViewModel
    
    @State private var isPriceAlertsEnabled: Bool

    @Query<PriceAlertsRequest>
    var priceAlerts: [PriceAlertData]

    init(model: PriceAlertsViewModel) {
        self.model = model
        _priceAlerts = Query(constant: model.request)
        _isPriceAlertsEnabled = State(initialValue: model.isPriceAlertsEnabled)
    }

    var body: some View {
        List {
            Toggle(
                model.enableTitle,
                isOn: $isPriceAlertsEnabled
            )
            .toggleStyle(AppToggleStyle())
            Section {
                ForEach(priceAlerts) {
                    ListAssetItemView(model: PriceAlertItemViewModel(data: $0))
                }
            }
        }
        .refreshable {
            await model.fetch()
        }
        .onChange(of: isPriceAlertsEnabled) { (_, newValue) in
            model.preferences.isPriceAlertsEnabled = newValue

            switch newValue {
            case true:
                Task {
                    model.preferences.isPushNotificationsEnabled = try await model.requestPermissions()
                    try await model.deviceUpdate()
                }
            case false:
                Task {
                    try await model.deviceUpdate()
                }
            }
        }
        .task {
            await model.fetch()
        }
        .navigationTitle(model.title)
    }
}

//#Preview {
//    PriceAlertsScene(
//        model: PriceAlertsViewModel(priceAlertService: PriceAlertService)
//    )
//}
