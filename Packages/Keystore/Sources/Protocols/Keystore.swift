// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI

public protocol Keystore: Sendable {
    func createWallet() throws -> SecretData
    @discardableResult
    func importWallet(name: String, type: KeystoreImportType, isWalletsEmpty: Bool, source: WalletSource) async throws -> Wallet
    func setupChains(chains: [Chain], for wallets: [Wallet]) throws -> [Wallet]
    func deleteKey(for wallet: Wallet) async throws
    func getPrivateKey(wallet: Wallet, chain: Chain) async throws -> Data
    func getPrivateKey(wallet: Wallet, chain: Chain, encoding: EncodingType) async throws -> SecretData
    func getMnemonic(wallet: Wallet) async throws -> SecretData
    func getPasswordAuthentication() throws -> KeystoreAuthentication
    func sign(hash: Data, wallet: Wallet, chain: Chain) async throws -> Data
    func destroy() throws
}
