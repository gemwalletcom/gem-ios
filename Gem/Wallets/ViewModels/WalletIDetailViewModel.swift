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
        case .single, .view, .privateKey:
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
    
    func getMnemonicWords() throws -> [String] {
        try keystore.getMnemonic(wallet: wallet)
    }
    
    func getPrivateKey(for chain: Chain) throws -> String {
        let encoding = getEncodingType(for: chain)
        return try keystore.getPrivateKey(wallet: wallet, chain: chain, encoding: encoding)
    }
    
    func getEncodingType(for chain: Chain) -> EncodingType {
        return chain.defaultKeyEncodingType
    }

    func delete() throws {
        try keystore.deleteWallet(for: wallet)

        if keystore.wallets.isEmpty {
            try CleanUpService(keystore: keystore).onDeleteAllWallets()
        }
    }
}
