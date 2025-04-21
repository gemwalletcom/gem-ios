// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Localization
import Primitives
import WalletService

public struct CreateWalletNavigationStack: View {
    @Environment(\.dismiss) private var dismiss

    @State private var navigationPath: NavigationPath = NavigationPath()
    @Binding private var isPresentingWallets: Bool
    
    private let walletService: WalletService

    public init(
        walletService: WalletService,
        isPresentingWallets: Binding<Bool>
    ) {
        self.walletService = walletService
        _isPresentingWallets = isPresentingWallets
    }

    public var body: some View {
        NavigationStack(path: $navigationPath) {
            CreateWalletScene(
                model: CreateWalletViewModel(
                    walletService: walletService,
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
                        walletService: walletService
                    ),
                    isPresentingWallets: $isPresentingWallets
                )
            }
        }
    }
}
