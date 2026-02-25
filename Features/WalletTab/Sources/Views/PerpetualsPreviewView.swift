// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import Store
import Perpetuals

struct PerpetualsPreviewView: View {
    
    @State private var viewModel: PerpetualsPreviewViewModel
    private let wallet: Wallet
    
    init(wallet: Wallet) {
        self.wallet = wallet
        _viewModel = State(initialValue: PerpetualsPreviewViewModel(walletId: wallet.walletId))
    }
    
    var body: some View {
        Group {
            if viewModel.hasNoPositions {
                NavigationLink(value: Scenes.Perpetuals()) {
                    ListItemView(
                        title: "Trade Perpetuals",
                        subtitle: viewModel.tradePerpetualsSubtitle
                    )
                }
            } else {
                PerpetualPositionsList(positions: viewModel.positions)
            }
        }
        .bindQuery(viewModel.positionsQuery, viewModel.walletBalanceQuery)
        .onChange(of: wallet.walletId) { _, newWalletId in
            viewModel.updateWallet(walletId: newWalletId)
        }
    }
}
