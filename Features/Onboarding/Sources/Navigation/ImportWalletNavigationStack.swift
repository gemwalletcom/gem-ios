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
    @State private var router: Routing
    
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
                model: AcceptTermsViewModel(),
                router: router,
                onNext: { router.push(to: ImportWalletDestination.importType) }
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
                        model: ImportWalletTypeViewModel(walletService: walletService),
                        router: router
                    )
                case .importWallet(let type):
                    ImportWalletScene(
                        model: ImportWalletViewModel(
                            type: type,
                            walletService: walletService
                        ),
                        router: router
                    )
                }
            }
        }
    }
}
