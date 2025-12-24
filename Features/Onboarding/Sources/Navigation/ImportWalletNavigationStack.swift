// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Localization
import PrimitivesComponents

public struct ImportWalletNavigationStack: View {
    @State private var model: ImportWalletViewModel

    public init(model: ImportWalletViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        NavigationStack(path: $model.navigationPath) {
            rootScene
                .toolbarDismissItem(title: .cancel, placement: .topBarLeading)
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: ImportWalletType.self) { type in
                    ImportWalletScene(
                        model: ImportWalletSceneViewModel(
                            walletService: model.walletService,
                            nameService: model.nameService,
                            type: type,
                            onComplete: model.onImportComplete
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
                .navigationDestination(for: Scenes.ImportWalletType.self) { _ in
                    importWalletTypeScene
                }
        }
    }

    @ViewBuilder
    private var rootScene: some View {
        if model.isAcceptTermsCompleted {
            importWalletTypeScene
        } else {
            AcceptTermsScene(model: AcceptTermsViewModel(onNext: { model.onNavigate(to: .importWalletType) }))
        }
    }
    
    private var importWalletTypeScene: some View {
        ImportWalletTypeScene(model: ImportWalletTypeViewModel(walletService: model.walletService))
    }
}
