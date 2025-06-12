// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Localization
import PriceAlerts
import Assets

struct AddAssetPriceAlertsNavigationStack: View {
    @Environment(\.dismiss) private var dismiss

    @State private var model: AddAssetPriceAlertsViewModel
    @State private var selectAssetModel: SelectAssetViewModel

    init(
        model: AddAssetPriceAlertsViewModel,
        selectAssetModel: SelectAssetViewModel
    ) {
        self.model = model
        self.selectAssetModel = selectAssetModel
    }

    // TODO: - review logic with self.selectAssetModel.selectAssetAction
    var body: some View {
        NavigationStack {
            SelectAssetScene(
                model: selectAssetModel,
                isPresentingAddToken: .constant(false)
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(Localized.Common.cancel) {
                        dismiss()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .task {
                self.selectAssetModel.onSelectAssetAction = {
                    model.onSelectAsset($0)
                    dismiss()
                }
            }
        }
    }
}
