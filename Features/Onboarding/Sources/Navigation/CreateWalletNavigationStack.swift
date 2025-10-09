// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Localization
import Primitives
import WalletService
import BannerService

public struct CreateWalletNavigationStack: View {
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
            Group {
                if walletService.isAcceptTermsCompleted {
                    securityReminderScene
                } else {
                    AcceptTermsScene(
                        model: AcceptTermsViewModel(
                            onNext: { navigationPath.append(Scenes.SecurityReminder())
                        })
                    )
                }
            }
            .toolbarDismissItem(title: .cancel, placement: .topBarLeading)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Scenes.VerifyPhrase.self) {
                VerifyPhraseWalletScene(
                    model: VerifyPhraseViewModel(
                        words: $0.words,
                        walletService: walletService,
                        onFinish: { isPresentingWallets.toggle() }
                    )
                )
            }
            .navigationDestination(for: Scenes.CreateWallet.self) { _ in
                ShowSecretDataScene(
                    model: CreateWalletViewModel(
                        walletService: walletService,
                        onCreateWallet: {
                            navigationPath.append(Scenes.VerifyPhrase(words: $0))
                        }
                    )
                )
            }
            .navigationDestination(for: Scenes.SecurityReminder.self) { _ in
                securityReminderScene
            }
        }
    }
    
    private var securityReminderScene: some View {
        SecurityReminderScene(
            model: SecurityReminderViewModelDefault(
                title: Localized.Wallet.New.title,
                onNext: { navigationPath.append(Scenes.CreateWallet()) }
            )
        )
    }
}
