// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI

public protocol Keystore: Sendable {
    func createWallet() -> [String]
    @discardableResult
    func importWallet(name: String, type: KeystoreImportType, isWalletsEmpty: Bool, isCreated: Bool) throws -> Wallet
    func setupChains(chains: [Chain], for wallets: [Wallet]) throws -> [Wallet]
    func deleteKey(for wallet: Wallet) throws
    func getPrivateKey(wallet: Wallet, chain: Chain) throws -> Data
    func getPrivateKey(wallet: Wallet, chain: Chain, encoding: EncodingType) throws -> String
    func getMnemonic(wallet: Wallet) throws -> [String]
    func getPasswordAuthentication() throws -> KeystoreAuthentication
    func sign(hash: Data, wallet: Wallet, chain: Chain) throws -> Data
    func destroy() throws
}
