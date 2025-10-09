// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Localization
import PrimitivesComponents

public struct ImportWalletNavigationStack: View {
    @State private var navigationPath: NavigationPath = NavigationPath()
    @Binding private var isPresentingWallets: Bool
    private let model: ImportWalletTypeViewModel
    private let nameService: any NameServiceable

    public init(
        model: ImportWalletTypeViewModel,
        nameService: any NameServiceable,
        isPresentingWallets: Binding<Bool>
    ) {
        self.model = model
        self.nameService = nameService
        _isPresentingWallets = isPresentingWallets
    }

    public var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                switch model.walletService.isAcceptTermsCompleted {
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
                        walletService: model.walletService,
                        nameService: nameService,
                        type: type,
                        onFinish: {
                            model.acceptTerms()
                            isPresentingWallets = false
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
