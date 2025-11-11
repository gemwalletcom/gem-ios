// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import WalletCore
import struct Formatters.MnemonicFormatter

public enum WalletIdentifier {
    case secret(words: [String])
    case single(chain: Chain, words: [String])
    case privateKey(chain: Chain, key: String)
    case address(address: String, chain: Chain)

    public func deriveAddress() throws -> (Chain, String) {
        switch self {
        case .secret(let words):
            return try deriveFromMnemonic(words: words, chain: .ethereum)
        case .single(let chain, let words):
            return try deriveFromMnemonic(words: words, chain: chain)
        case .privateKey(let chain, let key):
            let privateKey = try WalletKeyStore.decodeKey(key, chain: chain)
            let address = chain.coinType.deriveAddress(privateKey: privateKey)
            return (chain, address)
        case .address(let address, let chain):
            return (chain, address)
        }
    }

    private func deriveFromMnemonic(words: [String], chain: Chain) throws -> (Chain, String) {
        let mnemonic = MnemonicFormatter.fromArray(words: words)
        guard let wallet = HDWallet(mnemonic: mnemonic, passphrase: "") else {
            throw AnyError("Invalid mnemonic")
        }
        let key = wallet.getKeyForCoin(coin: chain.coinType)
        let address = chain.coinType.deriveAddress(privateKey: key)
        return (chain, address)
    }
}

public extension WalletIdentifier {
    static func from(_ type: KeystoreImportType) -> WalletIdentifier {
        switch type {
        case .phrase(let words, _): .secret(words: words)
        case .single(let words, let chain): .single(chain: chain, words: words)
        case .privateKey(let key, let chain): .privateKey(chain: chain, key: key)
        case .address(let address, let chain): .address(address: address, chain: chain)
        }
    }
}
