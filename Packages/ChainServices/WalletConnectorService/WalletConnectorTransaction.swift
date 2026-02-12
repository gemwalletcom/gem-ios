// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public enum WalletConnectorTransaction {
    case ethereum(WCEthereumTransaction)
    case solana(String, TransferDataOutputType)
    case sui(String, TransferDataOutputType)
    case ton(String, TransferDataOutputType)
    case bitcoin(String, TransferDataOutputType)
    case tron(String, TransferDataOutputType)
}
