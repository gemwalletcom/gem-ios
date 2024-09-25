import Foundation
import Primitives
import SwiftUI

public protocol Keystore: ObservableObject {
    var directory: URL { get }
    var currentWalletId: Primitives.WalletId? { get }
    var currentWallet: Primitives.Wallet? { get }
    func setCurrentWalletId(_ walletId: Primitives.WalletId?)
    func setCurrentWalletIndex(_ index: Int)
    var wallets: [Wallet] { get }
    func getCurrentWallet() throws -> Wallet
    func getWallet(_ walletId: WalletId) throws -> Wallet
    func createWallet() -> [String]
    @discardableResult
    func importWallet(name: String, type: KeystoreImportType) throws -> Wallet
    func setupChains(chains: [Chain]) throws
    func renameWallet(wallet: Wallet, newName: String) throws
    func deleteWallet(for wallet: Wallet) throws
    func getNextWalletIndex() throws -> Int
    func getPrivateKey(wallet: Primitives.Wallet, chain: Chain) throws -> Data
    func getPrivateKey(wallet: Primitives.Wallet, chain: Chain, encoding: EncodingType) throws -> String
    func getMnemonic(wallet: Wallet) throws -> [String]
    func getPasswordAuthentication() throws -> KeystoreAuthentication
    func sign(wallet: Wallet, message: SignMessage, chain: Chain) throws -> Data
    func destroy() throws
}

public enum KeystoreImportType {
    case phrase(words: [String], chains: [Chain])
    case single(words: [String], chain: Chain)
    case privateKey(text: String, chain: Chain)
    case address(chain: Chain, address: String)
}
