// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Localization
import WalletService

enum ImportWalletDestination: Hashable {
    case importWallet(ImportWalletType)
    case importType
}

public struct ImportWalletNavigationStack: View {
    @Environment(\.dismiss) private var dismiss
    @State private var router: Router<ImportWalletDestination>
    
    let walletService: WalletService

    public init(
        walletService: WalletService,
        onFinishFlow: VoidAction = nil
    ) {
        self.walletService = walletService
        self.router = Router(onFinishFlow: onFinishFlow)
    }

    public var body: some View {
        NavigationStack(path: $router.path) {
            AcceptTermsScene(
                model: AcceptTermsViewModel(navigation: self)
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(Localized.Common.cancel) {
                        dismiss()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: ImportWalletDestination.self) {
                switch $0 {
                case .importType:
                    ImportWalletTypeScene(
                        model: ImportWalletTypeViewModel(
                            walletService: walletService,
                            navigation: self
                        )
                    )
                case .importWallet(let type):
                    ImportWalletScene(
                        model: ImportWalletViewModel(
                            type: type,
                            walletService: walletService,
                            navigation: self
                        )
                    )
                }
            }
            .safariSheet(url: $router.isPresentingUrl)
        }
    }
}

// MARK: - Navigation

extension ImportWalletNavigationStack: AcceptTermsViewModelNavigation {
    func acceptTermsOnNext() {
        router.push(to: .importType)
    }
    
    func present(url: URL) {
        router.isPresentingUrl = url
    }
}

extension ImportWalletNavigationStack: ImportWalletTypeViewModelNavigation {
    func importWalletOnNext(type: ImportWalletType) {
        router.push(to: .importWallet(type))
    }
}

extension ImportWalletNavigationStack: ImportWalletViewModelNavigation {
    func importWalletOnNext() {
        router.onFinishFlow?()
    }
}
