// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletConnectorService
import Primitives
import PrimitivesTestKit
import ReownWalletKit
import Gemstone

final public class WalletConnectorSignableMock: WalletConnectorSignable {
    public let allChains: [Primitives.Chain] = []
    public init() {}
    public func addConnection(connection: WalletConnection) throws {}
    public func updateSessions(sessions: [WalletConnectionSession]) throws {}
    public func sessionReject(id: String, error: any Error) async throws {}
    public func getCurrentWallet() throws -> Primitives.Wallet { .mock() }
    public func getWallet(id: WalletId) throws -> Primitives.Wallet { .mock() }
    public func getChains(wallet: Wallet) -> [Primitives.Chain] { [] }
    public func getAccounts(wallet: Wallet, chains: [Primitives.Chain]) -> [Primitives.Account] { [] }
    public func getWallets(for proposal: WalletConnectSign.Session.Proposal) throws -> [Wallet] { [] }
    public func getMethods() -> [WalletConnectionMethods] { [] }
    public func getEvents() -> [WalletConnectionEvents] { [] }
    public func sessionApproval(payload: WCPairingProposal) async throws -> WalletId { .mock() }
    public func signMessage(sessionId: String, chain: Primitives.Chain, message: Gemstone.SignMessage) async throws -> String { "mock_signature" }
    public func signTransaction(sessionId: String, chain: Primitives.Chain, transaction: WalletConnectorTransaction) async throws -> String { "mock_signTransaction" }
    public func sendTransaction(sessionId: String, chain: Primitives.Chain, transaction: WalletConnectorTransaction) async throws -> String { "mock_sendTransaction" }
    public func sendRawTransaction(sessionId: String, chain: Primitives.Chain, transaction: String) async throws -> String { "mock_sendRawTransaction" }
}
