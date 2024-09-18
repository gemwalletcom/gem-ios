// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style

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
                    AssetImageView(assetImage: wallet.assetImage, size: Sizing.image.chain)
                    ListItemSelectionView(
                        title: wallet.name,
                        titleExtra: .none,
                        subtitle: .none,
                        subtitleExtra: .none,
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

// MARK: - Previews

#Preview {
    @Previewable @State var model = SellectWalletViewModel(wallets: [.main, .view], selectedWallet: .main)
    return NavigationStack {
        SelectWalletScene(model: $model)
    }
}
