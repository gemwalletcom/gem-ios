// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI

public protocol Keystore: Sendable {
    var directory: URL { get }
    var wallets: [Wallet] { get }
    func createWallet() -> [String]
    @discardableResult
    func importWallet(name: String, type: KeystoreImportType) throws -> Wallet
    func setupChains(chains: [Chain]) throws
    func deleteWallet(for wallet: Wallet) throws
    func getNextWalletIndex() throws -> Int
    func getPrivateKey(wallet: Primitives.Wallet, chain: Chain) throws -> Data
    func getPrivateKey(wallet: Primitives.Wallet, chain: Chain, encoding: EncodingType) throws -> String
    func getMnemonic(wallet: Wallet) throws -> [String]
    func getPasswordAuthentication() throws -> KeystoreAuthentication
    func sign(wallet: Wallet, message: SignMessage, chain: Chain) throws -> Data
    func destroy() throws
}
