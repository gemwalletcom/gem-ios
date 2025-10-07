// Copyright (c). Gem Wallet. All rights reserved.

import Components
import Localization
import Primitives
import PrimitivesComponents

struct ConfirmSenderViewModel {
    private let wallet: Wallet

    init(wallet: Wallet) {
        self.wallet = wallet
    }
}

// MARK: - ItemModelProvidable

extension ConfirmSenderViewModel: ItemModelProvidable {
    var itemModel: ConfirmTransferItemModel {
        let walletViewModel = WalletViewModel(wallet: wallet)
        return .sender(
            ListItemModel(
                title: Localized.Wallet.title,
                subtitle: wallet.name,
                imageStyle: ListItemImageStyle.list(
                    assetImage: walletViewModel.hasAvatar ? walletViewModel.avatarImage : nil
                )
            )
        )
    }
}
