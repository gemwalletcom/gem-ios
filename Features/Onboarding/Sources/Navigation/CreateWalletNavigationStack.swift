// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Localization
import Primitives
import WalletService

enum CreateWalletRoute: Hashable {
    case verifyPhrase([String])
    case createWallet
    case acceptTerms
}

public struct CreateWalletNavigationStack: View {
    @Environment(\.dismiss) private var dismiss
    
    private let walletService: WalletService
    
    @State private var router: Routing

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
                    onNext: {
                        router.push(to: CreateWalletRoute.acceptTerms)
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
            .navigationDestination(for: CreateWalletRoute.self) { route in
                switch route {
                case .createWallet:
                    CreateWalletScene(
                        model: CreateWalletViewModel(
                            walletService: walletService
                        ),
                        router: router
                    )
                case .verifyPhrase(let words):
                    VerifyPhraseWalletScene(
                        model: VerifyPhraseViewModel(
                            words: words,
                            walletService: walletService
                        ),
                        router: router
                    )
                case .acceptTerms:
                    AcceptTermsScene(
                        model: AcceptTermsViewModel(),
                        router: router
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
