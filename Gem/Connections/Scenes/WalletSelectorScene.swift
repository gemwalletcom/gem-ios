// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style

struct WalletsSelectorScene: View {
    @Environment(\.dismiss) private var dismiss

    @Binding private var model: WalletSelectorViewModel

    init(model: Binding<WalletSelectorViewModel>) {
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

extension WalletsSelectorScene {
    private func onSelect(wallet: WalletViewModel) {
        model.walletModel = wallet
        dismiss()
    }
}

// MARK: - Previews

#Preview {
    @State var model = WalletSelectorViewModel(wallets: [.main, .view], selectedWallet: .main)
    return NavigationStack {
        WalletsSelectorScene(model: $model)
    }
}
