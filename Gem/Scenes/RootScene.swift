// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Localization
import GemstonePrimitives
import Primitives
import Onboarding
import PriceService
import Components

struct RootScene: View {
    @State private var model: RootSceneViewModel
    
    init(model: RootSceneViewModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        VStack {
            if let currentWallet = model.currentWallet {
                MainTabView(
                    model: .init(wallet: currentWallet)
                )
                .alert(Localized.UpdateApp.title, isPresented: $model.availableRelease.mappedToBool()) {
                    if model.canSkipUpdate {
                        Button(Localized.Common.skip, role: .none) {
                            model.skipRelease()
                        }
                    } else {
                        Button(Localized.Common.cancel, role: .cancel) { }
                    }
                    Button(Localized.UpdateApp.action, role: .none) {
                        UIApplication.shared.open(PublicConstants.url(.appStore))
                    }
                } message: {
                    Text(Localized.UpdateApp.description(model.availableRelease?.version ?? ""))
                }
            } else {
                OnboardingNavigationView(
                    model: .init(walletService: model.walletService)
                )
            }
        }
        .onOpenURL { url in
            Task {
                await model.handleOpenUrl(url)
            }
        }
        .sheet(item: $model.isPresentingConnnectorSheet) { type in
            WalletConnectorNavigationStack(
                type: type,
                presenter: model.walletConnectorPresenter
            )
        }
        .confirmationDialog(
            Localized.WalletConnect.brandName,
            presenting: $model.isPresentingConnectorError,
            actions: { _ in
                Button(
                    Localized.Common.done,
                    role: .none,
                    action: {}
                )
            },
            message: {
                Text(model.isPresentingConnectorError.valueOrEmpty)
            }
        )
        .taskOnce(model.setup)
        .lockManaged(by: model.lockManager)
        .onChange(
            of: model.currentWallet,
            initial: true,
            model.onChangeWallet
        )
        .toast(
            isPresenting: $model.isPresentingConnectorBar,
            message: ToastMessage(
                title: "\(Localized.WalletConnect.brandName)...",
                image: SystemImage.network
            )
        )
    }
}

