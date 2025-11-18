// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import ChainService
import Localization
import Transfer
import ExplorerService
import Signer

struct ConfirmTransferNavigationStack: View {
    @Environment(\.viewModelFactory) private var viewModelFactory

    private let wallet: Wallet
    private let presentation: ConfirmTransferPresentation
    private let onComplete: VoidAction

    public init(
        wallet: Wallet,
        presentation: ConfirmTransferPresentation,
        onComplete: VoidAction
    ) {
        self.wallet = wallet
        self.presentation = presentation
        self.onComplete = onComplete
    }

    var body: some View {
        NavigationStack {
            ConfirmTransferScene(
                model: viewModelFactory.confirmTransferScene(
                    wallet: wallet,
                    presentation: presentation,
                    onComplete: onComplete
                )
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(Localized.Common.cancel) {
                        onComplete?()
                    }
                    .bold()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled(true)
        }
    }
}
