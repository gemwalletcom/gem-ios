// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Localization

public struct ImportWalletNavigationStack: View {
    @State private var navigationPath: NavigationPath = NavigationPath()
    @Binding private var isPresentingWallets: Bool
    private let model: ImportWalletTypeViewModel

    public init(
        model: ImportWalletTypeViewModel,
        isPresentingWallets: Binding<Bool>
    ) {
        self.model = model
        _isPresentingWallets = isPresentingWallets
    }

    public var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                switch model.walletService.isAcceptedTerms {
                case true:
                    ImportWalletTypeScene(model: model)
                case false:
                    AcceptTermsScene(model: AcceptTermsViewModel(
                        onNext: {
                            navigationPath.append(Scenes.ImportWalletType())
                        }
                    ))
                }
            }
            .toolbarDismissItem(title: .cancel, placement: .topBarLeading)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: ImportWalletType.self) { type in
                ImportWalletScene(
                    model: ImportWalletViewModel(
                        type: type,
                        walletService: model.walletService,
                        onFinishImport: {
                            model.walletService.acceptTerms()
                            isPresentingWallets.toggle()
                        }
                    )
                )
            }
            .navigationDestination(for: Scenes.ImportWalletType.self) { _ in
                ImportWalletTypeScene(model: model)
            }
        }
    }
}
