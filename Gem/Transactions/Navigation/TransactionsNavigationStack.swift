// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives

struct TransactionsNavigationStack: View {
    @Environment(\.navigationState) private var navigationState

    let model: TransactionsViewModel

    var body: some View {
        @Bindable var navigationState = navigationState
        NavigationStack(path: $navigationState.activity) {
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
