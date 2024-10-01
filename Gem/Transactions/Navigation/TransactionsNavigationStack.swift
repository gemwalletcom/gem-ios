// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives

struct TransactionsNavigationStack: View {
    
    let model: TransactionsViewModel
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            TransactionsScene(model: model)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: TransactionExtended.self) { transaction in
                TransactionScene(
                    input: TransactionSceneInput(transactionId: transaction.id, walletId: model.walletId)
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
