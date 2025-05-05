// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Localization
import Primitives
import WalletService

public struct CreateWalletNavigationStack: View {
    @Environment(\.dismiss) private var dismiss
    
    private let walletService: WalletService
    
    @State private var router: CreateWalletRouter

    public init(
        walletService: WalletService,
        onComplete: VoidAction
    ) {
        self.walletService = walletService
        self.router = CreateWalletRouter(onComplete: onComplete)
    }

    public var body: some View {
        NavigationStack(path: $router.stack) {
            SecurityReminderScene(
                model: SecurityReminderViewModelDefault(
                    title: Localized.Wallet.New.title,
                    onNext: {
                        router.push(to: .createWallet)
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
            .navigationDestination(for: CreateWalletRouter.Route.self) { route in
                switch route {
                case .createWallet:
                    CreateWalletScene(
                        model: CreateWalletViewModel(
                            walletService: walletService,
                            router: router
                        )
                    )
                case .verifyPhrase(let words):
                    VerifyPhraseWalletScene(
                        model: VerifyPhraseViewModel(
                            words: words,
                            walletService: walletService,
                            router: router
                        )
                    )
                }
            }
            .alert(item: $router.isPresentingAlert) {
                Alert(title: Text($0.title), message: Text($0.message))
            }
        }
    }
}
