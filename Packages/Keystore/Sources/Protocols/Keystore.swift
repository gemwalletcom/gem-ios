// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI

public protocol Keystore: Sendable {
    func createWallet() -> [String]
    @discardableResult
    func importWallet(name: String, type: KeystoreImportType, isWalletsEmpty: Bool) throws -> Primitives.Wallet
    func setupChains(chains: [Chain], for wallets: [Primitives.Wallet]) throws -> [Primitives.Wallet]
    func deleteKey(for wallet: Wallet) throws
    func getPrivateKey(wallet: Primitives.Wallet, chain: Chain) throws -> Data
    func getPrivateKey(wallet: Primitives.Wallet, chain: Chain, encoding: EncodingType) throws -> String
    func getMnemonic(wallet: Wallet) throws -> [String]
    func getPasswordAuthentication() throws -> KeystoreAuthentication
    func sign(wallet: Wallet, message: SignMessage, chain: Chain) throws -> Data
    func destroy() throws
}
