// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletConnector
import Primitives

struct WalletConnectorInteractor: WalletConnectorInteractable {
    func sessionApproval(payload: WCPairingProposal) async throws -> WalletId {
        return WalletId(id: "")
    }
    
    func signMessage(payload: SignMessagePayload) async throws -> String {
        return ""
    }
    
    func signTransaction(transferData: TransferData) async throws -> String {
        return ""
    }
    
    func sendTransaction(transferData: TransferData) throws -> String {
        return ""
    }
    
    func sendRawTransaction(transferData: TransferData) async throws -> String {
        return ""
    }
    
    func sessionReject(error: Error) {
        
    }
}
