// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Localization
import GemstonePrimitives
import Primitives

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
                .alert(Localized.UpdateApp.title, isPresented: $model.updateAvailableAlertSheetMessage.mappedToBool()) {
                    Button(Localized.Common.cancel, role: .cancel) { }
                    Button(Localized.UpdateApp.action, role: .none) {
                        UIApplication.shared.open(PublicConstants.url(.appStore))
                    }
                } message: {
                    Text(Localized.UpdateApp.description(model.updateAvailableAlertSheetMessage ?? ""))
                }
            } else {
                IntroNavigationView()
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
        .onChange(of: model.currentWallet, model.onWalletChange)
        .toast(
            isPresenting: $model.isPresentingConnectorBar,
            title: "\(Localized.WalletConnect.brandName)...",
            systemImage: SystemImage.network
        )
    }
}

