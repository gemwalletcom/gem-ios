// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Store
import Perpetuals
import Transfer
import Components
import PrimitivesComponents

struct AutocloseNavigationStack: View {
    @Environment(\.viewModelFactory) private var viewModelFactory

    @State private var navigationPath = NavigationPath()

    let position: PerpetualPositionData
    let wallet: Wallet
    let onComplete: VoidAction

    var body: some View {
        NavigationStack(path: $navigationPath) {
            AutocloseScene(
                model: AutocloseSceneViewModel(
                    type: .modify(position, onTransferAction: { navigationPath.append($0) })
                )
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarDismissItem(title: .done, placement: .topBarLeading) }
            .navigationDestination(for: TransferData.self) {
                ConfirmTransferScene(
                    model: viewModelFactory.confirmTransferScene(
                        wallet: wallet,
                        data: $0,
                        onComplete: onComplete
                    )
                )
            }
        }
    }
}
