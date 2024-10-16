// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Localization

struct AddTokenNavigationStack: View {
    
    let wallet: Wallet
    @State var isPresenting: Binding<Bool>
    var action: ((Asset) -> Void)?
    
    @Environment(\.chainServiceFactory) private var chainServiceFactory

    var body: some View {
        NavigationStack {
            AddTokenScene(
                model: AddTokenViewModel(
                    wallet: wallet,
                    service: AddTokenService(chainServiceFactory: chainServiceFactory)
                ),
                action: action
            )
            .navigationTitle(Localized.Settings.Networks.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(Localized.Common.cancel) {
                        isPresenting.wrappedValue = false
                    }
                }
            }
        }
    }
}
