// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keystore
import Primitives
import PrimitivesTestKit

public struct KeystoreMock: Keystore {
    public init() {}
    public func createWallet() -> [String] { LocalKeystore.words }
    public func importWallet(name: String, type: KeystoreImportType, isWalletsEmpty: Bool) throws -> Wallet { .mock() }
    public func setupChains(chains: [Primitives.Chain], for wallets: [Primitives.Wallet]) throws -> [Wallet] { [.mock()] }
    public func deleteKey(for wallet: Primitives.Wallet) throws {}
    public func getPrivateKey(wallet: Primitives.Wallet, chain: Primitives.Chain) throws -> Data { Data() }
    public func getPrivateKey(wallet: Primitives.Wallet, chain: Primitives.Chain, encoding: Primitives.EncodingType) throws -> String { .empty }
    public func getMnemonic(wallet: Primitives.Wallet) throws -> [String] { LocalKeystore.words }
    public func getPasswordAuthentication() throws -> KeystoreAuthentication { .none }
    public func sign(hash: Data, wallet: Primitives.Wallet, chain: Primitives.Chain) throws -> Data { Data() }
    public func destroy() throws {}
}
