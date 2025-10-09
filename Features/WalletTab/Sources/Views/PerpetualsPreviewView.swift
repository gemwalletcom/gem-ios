// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import Style
import PrimitivesComponents
import Formatters
import Store
import Perpetuals

public struct PerpetualsPreviewView: View {
    
    @State private var viewModel: PerpetualsPreviewViewModel
    private let wallet: Wallet
    
    public init(wallet: Wallet) {
        self.wallet = wallet
        _viewModel = State(initialValue: PerpetualsPreviewViewModel(walletId: wallet.walletId))
    }
    
    public var body: some View {
        Group {
            if viewModel.hasNoPositions {
                NavigationLink(value: Scenes.Perpetuals()) {
                    ListItemView(
                        title: "Trade Perpetuals",
                        subtitle: viewModel.tradePerpetualsSubtitle
                    )
                }
            } else {
                ForEach(viewModel.positions) { position in
                    NavigationLink(
                        value: Scenes.Perpetual(position.perpetualData)
                    ) {
                        ListAssetItemView(
                            model: PerpetualPositionItemViewModel(
                                model: PerpetualPositionViewModel(position)
                            )
                        )
                    }
                }
            }
        }
        .observeQuery(request: $viewModel.positionsRequest, value: $viewModel.positions)
        .observeQuery(request: $viewModel.walletBalanceRequest, value: $viewModel.walletBalance)
        .onChange(of: wallet.walletId) { _, newWalletId in
            viewModel.updateWallet(walletId: newWalletId)
        }
    }
}
