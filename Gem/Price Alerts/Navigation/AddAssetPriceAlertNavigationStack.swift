// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives

struct AddAssetPriceAlertsNavigationStack: View {
    @Environment(\.dismiss) private var dismiss

    @State private var model: AddAssetPriceAlertsViewModel
    @State private var selectAssetModel: SelectAssetViewModel

    @Binding private var navigationPath: NavigationPath

    init(
        model: AddAssetPriceAlertsViewModel,
        selectAssetModel: SelectAssetViewModel,
        navigationPath: Binding<NavigationPath>
    ) {
        self.model = model
        self.selectAssetModel = selectAssetModel
        _navigationPath = navigationPath
    }

    // TODO: - review logic with self.selectAssetModel.selectAssetAction
    var body: some View {
        NavigationStack(path: $navigationPath) {
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
                self.selectAssetModel.selectAssetAction = {
                    model.onSelectAsset($0)
                    dismiss()
                }
            }
        }
    }
}
