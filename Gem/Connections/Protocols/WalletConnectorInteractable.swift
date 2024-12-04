// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletConnector
import Primitives

protocol WalletConnectorInteractable: AnyObject {
    func sessionReject(error: any Error)
    func sessionApproval(payload: WCPairingProposal) async throws -> WalletId
    func signMessage(payload: SignMessagePayload) async throws -> String
    
    func signTransaction(transferData: WCTransferData) async throws -> String
    func sendTransaction(transferData: WCTransferData) async throws -> String
    func sendRawTransaction(transferData: WCTransferData) async throws -> String

    var isPresentingConnectionBar: Bool { get set }
    var isPresentingError: String? { get }
}
