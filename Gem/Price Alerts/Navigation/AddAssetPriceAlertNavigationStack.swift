// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives

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

    @State var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            SelectAssetScene(
                model: selectAssetModel,
                isPresentingAddToken: .constant(false),
                navigationPath: $navigationPath
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
        .task {
            self.selectAssetModel.selectAssetAction = {
                model.onSelectAsset($0)
                dismiss()
            }
        }
    }
}
