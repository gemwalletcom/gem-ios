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

    func signTransaction(transferData: WCTransferData) async throws -> String {
        return ""
    }

    func sendTransaction(transferData: WCTransferData) throws -> String {
        return ""
    }
    
    func sendRawTransaction(transferData: WCTransferData) async throws -> String {
        return ""
    }
    
    func sessionReject(error: any Error) {
        
    }
}
