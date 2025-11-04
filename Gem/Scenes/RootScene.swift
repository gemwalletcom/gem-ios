// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Localization
import GemstonePrimitives
import Primitives
import Onboarding
import PriceService
import Components
import Preferences

struct RootScene: View {
    @State private var model: RootSceneViewModel
    @Environment(\.observablePreferences) private var preferences

    init(model: RootSceneViewModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        VStack {
            if let currentWallet = model.currentWallet {
                MainTabView(
                    model: .init(wallet: currentWallet)
                )
                .alertSheet($model.updateVersionAlertMessage)
            } else {
                OnboardingNavigationView(
                    model: .init(
                        walletService: model.walletService,
                        nameService: model.nameService
                    )
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
        .onChange(of: preferences.currentWalletId, initial: true, model.updateCurrentWallet)
        .toast(
            isPresenting: $model.isPresentingConnectorBar,
            message: ToastMessage(
                title: "\(Localized.WalletConnect.brandName)...",
                image: SystemImage.network
            )
        )
    }
}

