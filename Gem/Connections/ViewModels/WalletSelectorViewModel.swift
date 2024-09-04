// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct WalletSelectorViewModel {
    private var wallets: [Wallet]
    private var selectedWallet: Wallet

    init(wallets: [Wallet], selectedWallet: Wallet) {
        self.wallets = wallets
        self.selectedWallet = selectedWallet
    }
    
    var title: String { Localized.Wallets.title }

    var walletModels: [WalletViewModel] {
        wallets.map({ WalletViewModel(wallet: $0) })
    }

    var walletModel: WalletViewModel {
        get {
            WalletViewModel(wallet: selectedWallet)
        }
        set {
            selectedWallet = newValue.wallet
        }
    }
}
