// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import Style

struct SelectAssetSceneNavigationStack: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.keystore) private var keystore
    @Environment(\.assetsService) private var assetsService

    @State private var isPresentingAddToken: Bool = false
    @State private var isPresentingFilteringView: Bool = false

    let model: SelectAssetViewModel

    var body: some View {
        @Bindable var model = model
        NavigationStack {
            SelectAssetScene(model: model, isPresentingAddToken: $isPresentingAddToken)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(Localized.Common.done) {
                            dismiss()
                        }
                        .bold()
                        .accessibilityIdentifier("cancel")
                    }
                    if model.showAddToken {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                isPresentingFilteringView = true
                            } label: {
                                Image(systemName: "line.horizontal.3.decrease")
                            }
                        }

                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                isPresentingAddToken = true
                            } label: {
                                Image(systemName: SystemImage.plus)
                            }
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $isPresentingAddToken) {
            AddTokenNavigationStack(
                wallet: model.wallet,
                isPresenting: $isPresentingAddToken,
                action: addAsset
            )
        }
        .sheet(isPresented: $isPresentingFilteringView) {
            NavigationStack {
                AssetsFilterScene(model: $model.filterModel)
            }
            .presentationDetents([.height(200)])
            .presentationDragIndicator(.visible)
        }
    }

    func addAsset(_ asset: Asset) {
        Task {
            try model.assetsService.addAsset(walletId: model.wallet.walletId, asset: asset)
        }
        dismiss()
    }
}
