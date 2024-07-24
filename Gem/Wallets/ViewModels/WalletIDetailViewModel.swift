import SwiftUI
import Primitives
import Keystore

struct WalletDetailViewModel {
    let wallet: Wallet
    let keystore: any Keystore

    var name: String {
        wallet.name
    }
    
    var title: String {
        return Localized.Common.wallet
    }
    
    var address: WalletDetailAddress? {
        switch wallet.type {
        case .multicoin:
            return .none
        case .single, .view:
            guard let account = wallet.accounts.first else { return .none }
            return WalletDetailAddress.account(
                SimpleAccount(
                    name: .none,
                    chain: account.chain,
                    address: account.address
                )
            )
        }
    }
}

// MARK: - Business Logic

extension WalletDetailViewModel {
    func rename(name: String) throws {
        try keystore.renameWallet(wallet: wallet, newName: name)
    }

    func getMnemonicWords() async throws -> [String] {
        try keystore.getMnemonic(wallet: wallet)
    }

    func getPrivateKey(chain: Chain) async throws -> String {
        let encoding = chain.keyEncodingTypes.first
        return try keystore.getPrivateKey(wallet: wallet, chain: chain, encoding: encoding)
    }

    func delete() throws {
        try keystore.deleteWallet(for: wallet)

        if keystore.wallets.isEmpty {
            try CleanUpService(keystore: keystore).onDeleteAllWallets()
        }
    }
}
