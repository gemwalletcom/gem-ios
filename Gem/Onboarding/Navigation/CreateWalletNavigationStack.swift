// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

struct CreateWalletNavigationStack: View {
    
    @State var isPresenting: Binding<Bool>
    
    @Environment(\.keystore) private var keystore
    
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            CreateWalletScene(
                model: CreateWalletViewModel(
                    navigationPath: $navigationPath,
                    keystore: keystore
                )
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(Localized.Common.cancel) {
                        isPresenting.wrappedValue.toggle()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Scenes.VerifyPhrase.self) {
                VerifyPhraseWalletScene(
                    model: VerifyPhraseViewModel(
                        navigationPath: $navigationPath,
                        words: $0.words,
                        keystore: keystore
                    )
                )
            }
        }
    }
}
