// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

struct CreateWalletNavigationStack: View {
    
    @State var isPresenting: Binding<Bool>
    
    @Environment(\.keystore) private var keystore
    
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            CreateWalletScene(
                path: $path,
                model: CreateWalletViewModel(keystore: keystore)
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
                    path: $path,
                    model: VerifyPhraseViewModel(words: $0.words, keystore: keystore)
                )
            }
        }
    }
}
