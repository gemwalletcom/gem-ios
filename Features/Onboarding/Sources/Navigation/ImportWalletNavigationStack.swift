// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Localization
import PrimitivesComponents

public struct ImportWalletNavigationStack: View {
    @State private var model: ImportWalletViewModel
    @State private var navigationPath = NavigationPath()

    public init(model: ImportWalletViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        NavigationStack(path: $navigationPath) {
            rootScene
                .toolbarDismissItem(type: .close, placement: .topBarLeading)
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: ImportWalletType.self) { type in
                    ImportWalletScene(
                        model: ImportWalletSceneViewModel(
                            walletService: model.walletService,
                            nameService: model.nameService,
                            type: type,
                            onComplete: onImportComplete
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
                .navigationDestination(for: Scenes.ImportWalletType.self) { _ in
                    importWalletTypeScene
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
            importWalletTypeScene
        } else {
            AcceptTermsScene(model: AcceptTermsViewModel(onNext: { navigate(to: .importWalletType) }))
        }
    }

    private var importWalletTypeScene: some View {
        ImportWalletTypeScene(model: ImportWalletTypeViewModel(walletService: model.walletService))
    }
}

// MARK: - Actions

extension ImportWalletNavigationStack {
    func navigate(to route: ImportWalletRoute) {
        switch route {
        case .importWalletType: navigationPath.append(Scenes.ImportWalletType())
        case .walletProfile(let wallet): navigationPath.append(Scenes.WalletProfile(wallet: wallet))
        }
    }

    func onImportComplete(data: WalletImportData) {
        Task {
            do {
                let wallet = try await model.importWallet(data: data)
                navigate(to: .walletProfile(wallet: wallet))
            } catch {
                debugLog("Failed to import wallet: \(error)")
            }
        }
    }

    func onSetupWalletComplete(_ wallet: Wallet) {
        Task {
            do {
                try await model.setupWalletComplete()
            } catch {
                debugLog("Failed to setup wallet: \(error)")
            }
        }
    }
}
