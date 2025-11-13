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
            switch model.appState {
            case .onboarding:
                OnboardingNavigationView(model: model.onboardingViewModel)
            case .authenticated(let wallet):
                MainTabView(model: MainTabViewModel(wallet: wallet))
                    .alertSheet($model.updateVersionAlertMessage)
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
        .alert(
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
            of: model.walletService.currentWallet,
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

