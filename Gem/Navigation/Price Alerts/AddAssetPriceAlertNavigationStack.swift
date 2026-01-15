// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import PriceAlerts
import Assets
import PrimitivesComponents

struct AddAssetPriceAlertsNavigationStack: View {
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
                ToolbarDismissItem(type: .close, placement: .topBarLeading)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
