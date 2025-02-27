// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import PrimitivesComponents
import FileStore

struct SellectWalletViewModel {
    private var wallets: [Wallet]
    private var selectedWallet: Wallet

    public init(wallets: [Wallet], selectedWallet: Wallet) {
        self.wallets = wallets
        self.selectedWallet = selectedWallet
    }
    
    var title: String { Localized.Wallets.title }

    var walletModels: [WalletViewModel] {
        wallets.map({ WalletViewModel(wallet: $0, fileStore: FileStore()) })
    }

    var walletModel: WalletViewModel {
        get {
            WalletViewModel(wallet: selectedWallet, fileStore: FileStore())
        }
        set {
            selectedWallet = newValue.wallet
        }
    }
}
