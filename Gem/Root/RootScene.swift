// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Localization
import GemstonePrimitives
import Components
import Primitives

struct RootScene: View {
    @State private var model: RootSceneViewModel

    init(model: RootSceneViewModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        VStack {
            if let currentWallet = model.keystore.currentWallet {
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
                onComplete: model.handleWalletConnectorComplete(type:),
                onCancel: model.handleWalletConnectorCancel(type:))
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
                Text(model.walletConnectorInteractor.isPresentingError.valueOrEmpty)
            }
        )
        .taskOnce(model.setup)
        .onChange(of: model.keystore.currentWallet, model.onWalletChange)
        .toast(
            isPresenting: $model.isPresentingConnectorBar,
            title: "\(Localized.WalletConnect.brandName)...",
            systemImage: SystemImage.network
        )
    }
}
