// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives

struct TransactionsNavigationStack: View {
    @Environment(\.navigationState) private var navigationState

    let model: TransactionsViewModel

    private var navigationPath: Binding<NavigationPath> {
        Binding(
            get: { navigationState.activity },
            set: { navigationState.activity = $0 }
        )
    }

    var body: some View {
        NavigationStack(path: navigationPath) {
            TransactionsScene(model: model)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle(model.title)
                .navigationDestination(for: TransactionExtended.self) {
                    TransactionScene(
                        input: TransactionSceneInput(transactionId: $0.id, walletId: model.walletId)
                    )
                }
                .navigationDestination(for: Scenes.Asset.self) {
                    AssetScene(
                        wallet: model.wallet,
                        input: AssetSceneInput(walletId: model.walletId, assetId: $0.asset.id),
                        isPresentingAssetSelectType: Binding.constant(.none)
                    )
                }
        }
    }
}
