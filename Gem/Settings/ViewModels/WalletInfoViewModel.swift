import SwiftUI
import Primitives
import Keystore

enum WalletInfoAddress {
    case account(SimpleAccount)
}

struct WalletInfoViewModel {
    
    let wallet: Wallet
    let keystore: any Keystore

    var name: String {
        wallet.name
    }
    
    var title: String {
        return Localized.Common.wallet
    }
    
    func rename(name: String) throws {
        try keystore.renameWallet(wallet: wallet, newName: name)
    }
    
    var address: WalletInfoAddress? {
        switch wallet.type {
        case .multicoin:
            return .none
        case .single,
            .view:
            guard let account = wallet.accounts.first else {
                return .none
            }
            return WalletInfoAddress.account(
                SimpleAccount(
                    name: .none,
                    chain: account.chain,
                    address: account.address
                )
            )
        }
    }
}

