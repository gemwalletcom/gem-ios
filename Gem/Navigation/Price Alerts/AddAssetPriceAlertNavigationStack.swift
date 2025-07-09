// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Localization
import PriceAlerts
import Assets

struct AddAssetPriceAlertsNavigationStack: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectAssetModel: SelectAssetViewModel

    init(selectAssetModel: SelectAssetViewModel) {
        self.selectAssetModel = selectAssetModel
    }

    var body: some View {
        NavigationStack {
            SelectAssetScene(
                model: selectAssetModel
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(Localized.Common.cancel) {
                        dismiss()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
