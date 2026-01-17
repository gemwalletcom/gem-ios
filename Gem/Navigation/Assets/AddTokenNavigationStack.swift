// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import ChainService
import Assets
import Style
import Localization

struct AddTokenNavigationStack: View {
    
    let wallet: Wallet
    @State var isPresenting: Binding<Bool>
    
    @Environment(\.chainServiceFactory) private var chainServiceFactory
    @Environment(\.assetsService) private var assetsService

    var body: some View {
        NavigationStack {
            AddTokenScene(
                model: AddTokenViewModel(
                    wallet: wallet,
                    service: AddTokenService(chainServiceFactory: chainServiceFactory)
                ),
                action: addAsset
            )
            .navigationTitle(Localized.Settings.Networks.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("", systemImage: SystemImage.xmark) {
                        isPresenting.wrappedValue = false
                    }
                }
            }
        }
    }
}

extension AddTokenNavigationStack {
    private func addAsset(_ asset: Asset) {
        Task {
            try assetsService.addNewAsset(walletId: wallet.walletId, asset: asset)
        }
        isPresenting.wrappedValue = false
    }
}
