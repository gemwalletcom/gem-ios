// Copyright (c). Gem Wallet. All rights reserved.

import WalletConnectorService
import Primitives

public enum WalletConnectorSheetType: Sendable, Identifiable {
    case transferData(TransferDataCallback<WCTransferData>)
    case signMessage(TransferDataCallback<SignMessagePayload>)
    case connectionProposal(TransferDataCallback<WCPairingProposal>)

    public var id: Int {
        switch self {
        case .transferData(let callback): callback.id.hashValue
        case .signMessage(let callback): callback.id.hashValue
        case .connectionProposal(let callback): callback.id.hashValue
        }
    }
}
