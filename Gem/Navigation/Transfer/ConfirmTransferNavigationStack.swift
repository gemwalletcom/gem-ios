// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import ChainService
import Transfer
import ExplorerService
import Signer
import Style

struct ConfirmTransferNavigationStack: View {
    @Environment(\.viewModelFactory) private var viewModelFactory

    private let wallet: Wallet
    private let transferData: TransferData
    private let onComplete: VoidAction

    public init(
        wallet: Wallet,
        transferData: TransferData,
        onComplete: VoidAction
    ) {
        self.wallet = wallet
        self.transferData = transferData
        self.onComplete = onComplete
    }
    
    var body: some View {
        NavigationStack {
            ConfirmTransferScene(
                model: viewModelFactory.confirmTransferScene(
                    wallet: wallet,
                    data: transferData,
                    onComplete: onComplete
                )
            )
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("", systemImage: SystemImage.xmark) {
                        onComplete?()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled(true)
        }
    }
}
