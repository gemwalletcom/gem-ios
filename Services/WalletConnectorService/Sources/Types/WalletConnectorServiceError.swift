// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum WalletConnectorServiceError: Error {
    case unresolvedMethod(String)
    case unresolvedChainId(String)
    case walletsUnsupported
    case wrongSignParameters
    case wrongSendParameters
}
