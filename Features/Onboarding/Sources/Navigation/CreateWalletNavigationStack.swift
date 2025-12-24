// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Localization
import Primitives
import WalletService

public struct CreateWalletNavigationStack: View {

    @State private var model: CreateWalletModel

    public init(model: CreateWalletModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        NavigationStack(path: $model.navigationPath) {
            rootScene
                .toolbarDismissItem(title: .cancel, placement: .topBarLeading)
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: Scenes.VerifyPhrase.self) { scene in
                    VerifyPhraseWalletScene(
                        model: VerifyPhraseViewModel(
                            words: scene.words,
                            onComplete: model.onVerifyPhraseComplete
                        )
                    )
                }
                .navigationDestination(for: Scenes.WalletProfile.self) { scene in
                    SetupWalletScene(
                        model: SetupWalletViewModel(
                            wallet: scene.wallet,
                            walletService: model.walletService,
                            onSelectImage: { model.onNavigate(to: .selectImage(wallet: $0)) },
                            onComplete: model.onSetupWalletComplete
                        )
                    )
                    .navigationBarBackButtonHidden()
                    .interactiveDismissDisabled()
                }
                .navigationDestination(for: Scenes.WalletSelectImage.self) {
                    WalletImageScene(
                        model: WalletImageViewModel(
                            wallet: $0.wallet,
                            source: .onboarding,
                            avatarService: model.avatarService
                        )
                    )
                }
                .navigationDestination(for: Scenes.CreateWallet.self) { _ in
                    ShowSecretDataScene(
                        model: NewSecretPhraseViewModel(
                            walletService: model.walletService,
                            onCreateWallet: { model.onNavigate(to: .verifyPhrase(words: $0)) }
                        )
                    )
                }
                .navigationDestination(for: Scenes.SecurityReminder.self) { _ in
                    securityReminderScene
                }
        }
    }
    
    @ViewBuilder
    private var rootScene: some View {
        if model.isAcceptTermsCompleted {
            securityReminderScene
        } else {
            AcceptTermsScene(model: AcceptTermsViewModel(onNext: { model.onNavigate(to: .securityReminder) }))
        }
    }

    private var securityReminderScene: some View {
        SecurityReminderScene(
            model: SecurityReminderViewModelDefault(
                title: Localized.Wallet.New.title,
                onNext: { model.onNavigate(to: .createWallet) }
            )
        )
    }
}
