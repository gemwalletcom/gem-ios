// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletConnectorService
import Primitives

@MainActor
public protocol WalletConnectorInteractable: Sendable {
    func sessionReject(error: any Error) async
    func sessionApproval(payload: WCPairingProposal) async throws -> WalletId
    func signMessage(payload: SignMessagePayload) async throws -> String
    
    func signTransaction(transferData: WCTransferData) async throws -> String
    func sendTransaction(transferData: WCTransferData) async throws -> String
    func sendRawTransaction(transferData: WCTransferData) async throws -> String

    var isPresentingConnectionBar: Bool { get set }
    var isPresentingError: String? { get }
}
