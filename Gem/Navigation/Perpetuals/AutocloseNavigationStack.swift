// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Store
import Perpetuals
import Transfer
import Components
import Localization

struct AutocloseNavigationStack: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.viewModelFactory) private var viewModelFactory

    @State private var navigationPath = NavigationPath()

    let position: PerpetualPositionData
    let wallet: Wallet
    let onComplete: VoidAction

    init(
        position: PerpetualPositionData,
        wallet: Wallet,
        onComplete: VoidAction
    ) {
        self.position = position
        self.wallet = wallet
        self.onComplete = onComplete
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            AutocloseScene(
                model: AutocloseSceneViewModel(
                    position: position,
                    onTransferAction: {
                        navigationPath.append($0)
                    }
                )
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text(Localized.Common.done)
                            .bold()
                    }
                }
            }
            .navigationDestination(for: TransferData.self) {
                ConfirmTransferScene(
                    model: viewModelFactory.confirmTransferScene(
                        wallet: wallet,
                        presentation: .confirm($0),
                        onComplete: {
                            onComplete?()
                        }
                    )
                )
            }
        }
    }
}
