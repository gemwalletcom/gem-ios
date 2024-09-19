// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives

struct AddAssetPriceAlertsNavigationStack: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.keystore) private var keystore
    @Environment(\.assetsService) private var assetsService
    @Environment(\.walletsService) private var walletsService

    let model: AddAssetPriceAlertsViewModel

    @State var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            SelectAssetScene(
                model: SelectAssetViewModel(
                    wallet: keystore.currentWallet!,
                    keystore: keystore,
                    selectType: .priceAlert,
                    assetsService: assetsService,
                    walletsService: walletsService,
                    selectAssetAction: {
                        model.onSelectAsset($0)
                        dismiss()
                    }
                ),
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
    }
}
