// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum WalletConnectorServiceError: Error, Equatable {
    case unresolvedMethod(String)
    case unresolvedChainId(String)
    case walletsUnsupported
    case wrongSignParameters
    case wrongSendParameters
    case invalidOrigin
}
