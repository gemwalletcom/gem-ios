// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

struct CreateWalletNavigationStack: View {
    
    @Environment(\.keystore) private var keystore
    @Environment(\.dismiss) private var dismiss

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
                        dismiss()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Scenes.VerifyPhrase.self) {
                VerifyPhraseWalletScene(
                    model: VerifyPhraseViewModel(
                        words: $0.words,
                        keystore: keystore
                    )
                )
            }
        }
    }
}
