// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Localization
import Primitives
import WalletService

public struct CreateWalletNavigationStack: View {

    @State private var model: CreateWalletModel
    @State private var navigationPath = NavigationPath()

    public init(model: CreateWalletModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        NavigationStack(path: $navigationPath) {
            rootScene
                .toolbarDismissItem(type: .close, placement: .topBarLeading)
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: Scenes.VerifyPhrase.self) { scene in
                    VerifyPhraseWalletScene(
                        model: VerifyPhraseViewModel(
                            words: scene.words,
                            onComplete: onVerifyPhraseComplete
                        )
                    )
                }
                .navigationDestination(for: Scenes.WalletProfile.self) { scene in
                    SetupWalletScene(
                        model: SetupWalletViewModel(
                            wallet: scene.wallet,
                            walletService: model.walletService,
                            onSelectImage: { model.presentSelectImage(wallet: $0) },
                            onComplete: onSetupWalletComplete
                        )
                    )
                    .navigationBarBackButtonHidden()
                    .interactiveDismissDisabled()
                }
                .navigationDestination(for: Scenes.CreateWallet.self) { _ in
                    ShowSecretDataScene(
                        model: NewSecretPhraseViewModel(
                            walletService: model.walletService,
                            onCreateWallet: { navigate(to: .verifyPhrase(words: $0)) }
                        )
                    )
                }
                .navigationDestination(for: Scenes.SecurityReminder.self) { _ in
                    securityReminderScene
                }
                .sheet(item: $model.isPresentingSelectImageWallet) { wallet in
                    NavigationStack {
                        WalletImageScene(
                            model: WalletImageViewModel(
                                wallet: wallet,
                                source: .onboarding,
                                avatarService: model.avatarService
                            )
                        )
                        .toolbarDismissItem(type: .close, placement: .topBarLeading)
                    }
                }
        }
    }

    @ViewBuilder
    private var rootScene: some View {
        if model.isAcceptTermsCompleted {
            securityReminderScene
        } else {
            AcceptTermsScene(model: AcceptTermsViewModel(onNext: { navigate(to: .securityReminder) }))
        }
    }

    private var securityReminderScene: some View {
        SecurityReminderScene(
            model: SecurityReminderViewModelDefault(
                title: Localized.Wallet.New.title,
                onNext: { navigate(to: .createWallet) }
            )
        )
    }
}

// MARK: - Actions

extension CreateWalletNavigationStack {
    func navigate(to route: CreateWalletRoute) {
        switch route {
        case .securityReminder: navigationPath.append(Scenes.SecurityReminder())
        case .createWallet: navigationPath.append(Scenes.CreateWallet())
        case .verifyPhrase(let words): navigationPath.append(Scenes.VerifyPhrase(words: words))
        case .walletProfile(let wallet): navigationPath.append(Scenes.WalletProfile(wallet: wallet))
        }
    }

    func onVerifyPhraseComplete(words: [String]) {
        Task {
            do {
                let wallet = try await model.createWallet(words: words)

                if model.hasExistingWallets {
                    navigate(to: .walletProfile(wallet: wallet))
                } else {
                    onSetupWalletComplete(wallet: wallet)
                }
            } catch {
                debugLog("Failed to create wallet: \(error)")
            }
        }
    }

    func onSetupWalletComplete(wallet: Wallet) {
        Task {
            do {
                try await model.setupWalletComplete(wallet: wallet)
            } catch {
                debugLog("Failed to setup wallet: \(error)")
            }
        }
    }
}
