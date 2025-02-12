// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Localization
import Primitives
import Keystore

public struct CreateWalletNavigationStack: View {
    @Environment(\.dismiss) private var dismiss

    @State private var navigationPath: NavigationPath = NavigationPath()
    @Binding private var isPresentingWallets: Bool
    
    private let keystore: any Keystore

    public init(
        keystore: any Keystore,
        isPresentingWallets: Binding<Bool>
    ) {
        self.keystore = keystore
        _isPresentingWallets = isPresentingWallets
    }

    public var body: some View {
        NavigationStack(path: $navigationPath) {
            CreateWalletScene(
                model: CreateWalletViewModel(
                    keystore: keystore,
                    onCreateWallet: {
                        navigationPath.append(Scenes.VerifyPhrase(words: $0))
                    }
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
                    ),
                    isPresentingWallets: $isPresentingWallets
                )
            }
        }
    }
}
