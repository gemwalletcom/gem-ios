// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletConnector
import Primitives

protocol WalletConnectorInteractable {
    func sessionReject(error: Error)
    func sessionApproval(payload: WalletConnectionSessionProposal) async throws -> Bool
    func signMessage(payload: SignMessagePayload) async throws -> String
    
    func signTransaction(transferData: TransferData) async throws -> String
    func sendTransaction(transferData: TransferData) async throws -> String
    func sendRawTransaction(transferData: TransferData) async throws -> String
}
