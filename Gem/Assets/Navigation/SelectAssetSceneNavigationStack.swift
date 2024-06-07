// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import Style

struct SelectAssetSceneNavigationStack: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let model: SelectAssetViewModel
    @State var isPresenting: Binding<SelectAssetType?>
    @State private var isPresentingAddToken: Bool = false

    @Environment(\.keystore) private var keystore
    @Environment(\.assetsService) private var assetsService
    @Environment(\.walletService) private var walletService
    
    var body: some View {
        NavigationStack {
            SelectAssetScene(model: model, isPresentingAddToken: $isPresentingAddToken)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(Localized.Common.done) {
                        isPresenting.wrappedValue = nil
                    }
                    .bold()
                    .accessibilityIdentifier("cancel")
                }
                if model.showAddToken {
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
    }
    
    func addAsset(_ asset: Asset) {
        Task {
            try model.assetsService.addAsset(walletId: model.wallet.id, asset: asset)
        }
        dismiss()
    }
}
