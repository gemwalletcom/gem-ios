// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Localization
import Primitives
import ManageWalletService

public struct CreateWalletNavigationStack: View {
    @Environment(\.dismiss) private var dismiss

    @State private var navigationPath: NavigationPath = NavigationPath()
    @Binding private var isPresentingWallets: Bool
    
    private let manageWalletService: ManageWalletService

    public init(
        manageWalletService: ManageWalletService,
        isPresentingWallets: Binding<Bool>
    ) {
        self.manageWalletService = manageWalletService
        _isPresentingWallets = isPresentingWallets
    }

    public var body: some View {
        NavigationStack(path: $navigationPath) {
            CreateWalletScene(
                model: CreateWalletViewModel(
                    manageWalletService: manageWalletService,
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
                        manageWalletService: manageWalletService
                    ),
                    isPresentingWallets: $isPresentingWallets
                )
            }
        }
    }
}
