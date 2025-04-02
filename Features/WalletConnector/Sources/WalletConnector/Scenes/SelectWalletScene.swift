// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style
import PrimitivesComponents

struct SelectWalletScene: View {
    @Environment(\.dismiss) private var dismiss

    @Binding private var model: SellectWalletViewModel

    init(model: Binding<SellectWalletViewModel>) {
        _model = model
    }

    var body: some View {
        List {
            ForEach(model.walletModels) { wallet in
                HStack {
                    ListItemSelectionView(
                        title: wallet.name,
                        titleExtra: .none,
                        titleTag: .none,
                        titleTagType: .none,
                        subtitle: .none,
                        subtitleExtra: .none,
                        imageStyle: .asset(assetImage: wallet.avatarImage),
                        value: wallet,
                        selection: model.walletModel,
                        action: onSelect(wallet:)
                    )
                }
            }
        }
        .navigationTitle(model.title)
    }
}

// MARK: - Actions

extension SelectWalletScene {
    private func onSelect(wallet: WalletViewModel) {
        model.walletModel = wallet
        dismiss()
    }
}
