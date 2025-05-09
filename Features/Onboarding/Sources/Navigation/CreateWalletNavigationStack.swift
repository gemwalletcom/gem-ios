// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Localization
import Primitives
import WalletService

enum CreateWalletDestination: Hashable {
    case acceptTerms
    case createWallet
    case verifyPhrase([String])
}

public struct CreateWalletNavigationStack: View {
    @Environment(\.dismiss) private var dismiss
    
    private let walletService: WalletService
    
    @State private var router: Router<CreateWalletDestination>

    public init(
        walletService: WalletService,
        onFinishFlow: VoidAction
    ) {
        self.walletService = walletService
        self.router = Router(onFinishFlow: onFinishFlow)
    }

    public var body: some View {
        NavigationStack(path: $router.path) {
            SecurityReminderScene(
                model: SecurityReminderViewModelDefault(
                    title: Localized.Wallet.New.title,
                    onNext: securityReminderOnNext
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
            .navigationDestination(for: CreateWalletDestination.self) {
                switch $0 {
                case .acceptTerms:
                    AcceptTermsScene(
                        model: AcceptTermsViewModel(
                            navigation: self
                        )
                    )
                case .createWallet:
                    CreateWalletScene(
                        model: CreateWalletViewModel(
                            walletService: walletService,
                            navigation: self
                        )
                    )
                case .verifyPhrase(let words):
                    VerifyPhraseWalletScene(
                        model: VerifyPhraseViewModel(
                            words: words,
                            walletService: walletService,
                            navigation: self
                        )
                    )
                }
            }
            .alert(item: $router.isPresentingAlert) {
                Alert(title: Text($0.title), message: Text($0.message))
            }
            .safariSheet(url: $router.isPresentingUrl)
        }
    }
}

// MARK: - Navigation

extension CreateWalletNavigationStack {
    func securityReminderOnNext() {
        router.push(to: .acceptTerms)
    }
}

extension CreateWalletNavigationStack: CreateWalletViewModelNavigation {
    func createWalletOnNext(words: [String]) {
        router.push(to: .verifyPhrase(words))
    }
}

extension CreateWalletNavigationStack: VerifyPhraseViewModelNavigation {
    func verifyPhraseOnNext() {
        router.onFinishFlow?()
    }
    
    func show(error: any Error) {
        router.presentAlert(
            title: Localized.Errors.createWallet(""),
            message: error.localizedDescription
        )
    }
}

extension CreateWalletNavigationStack: AcceptTermsViewModelNavigation {
    func acceptTermsOnNext() {
        router.push(to: .createWallet)
    }
    
    func present(url: URL) {
        router.isPresentingUrl = url
    }
}
