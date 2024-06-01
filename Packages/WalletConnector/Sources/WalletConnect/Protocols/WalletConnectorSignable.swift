// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public protocol WalletConnectorSignable {
    func updateSessions(sessions: [WalletConnectionSession]) throws
    func sessionReject(id: String, error: Error) throws
    func getWallet() throws -> Primitives.Wallet
    func getChains() throws -> [Primitives.Chain]
    func getAccounts() throws -> [Primitives.Account]
    func getMethods() throws -> [WalletConnectionMethods]
    func getEvents() throws -> [WalletConnectionEvents]
    func sessionApproval(payload: WalletConnectionSessionProposal) async throws -> Bool
    func signMessage(sessionId: String, chain: Chain, message: SignMessage) async throws -> String
    
    func signTransaction(sessionId: String, chain: Chain, transaction: WalletConnectorTransaction) async throws -> String
    func sendTransaction(sessionId: String, chain: Chain, transaction: WalletConnectorTransaction) async throws -> String
    func sendRawTransaction(sessionId: String, chain: Chain, transaction: String) async throws -> String
}
