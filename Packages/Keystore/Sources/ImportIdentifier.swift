// Copyright (c). Gem Wallet. All rights reserved.

import struct Formatters.MnemonicFormatter
import Foundation
import Primitives
import WalletCore

public enum ImportIdentifier {
    case phrase(secretData: SecretData)
    case single(chain: Chain, secretData: SecretData)
    case privateKey(chain: Chain, secretData: SecretData)
    case address(address: String, chain: Chain)

    public func walletIdentifier() throws -> WalletIdentifier {
        let (chain, address) = try deriveAddress()
        switch self {
        case .phrase: return .multicoin(address: address)
        case .single: return .single(chain: chain, address: address)
        case .privateKey: return .privateKey(chain: chain, address: address)
        case .address: return .view(chain: chain, address: address)
        }
    }

    public func deriveAddress() throws -> (Chain, String) {
        switch self {
        case let .phrase(secretData):
            return try deriveFromMnemonic(words: secretData.words, chain: .ethereum)
        case let .single(chain, secretData):
            return try deriveFromMnemonic(words: secretData.words, chain: chain)
        case let .privateKey(chain, secretData):
            let privateKey = try WalletKeyStore.decodeKey(secretData.string, chain: chain)
            let address = chain.coinType.deriveAddress(privateKey: privateKey)
            return (chain, address)
        case let .address(address, chain):
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

public extension ImportIdentifier {
    static func from(_ type: KeystoreImportType) -> ImportIdentifier {
        switch type {
        case let .phrase(secretData, _): .phrase(secretData: secretData)
        case let .single(secretData, chain): .single(chain: chain, secretData: secretData)
        case let .privateKey(secretData, chain): .privateKey(chain: chain, secretData: secretData)
        case let .address(address, chain): .address(address: address, chain: chain)
        }
    }
}
