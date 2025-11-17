// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletConnectorService
import Localization

extension WalletConnectorServiceError: @retroactive LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unresolvedMethod:
            Localized.Errors.Connections.unsupportedMethod
        case .unresolvedChainId:
            Localized.Errors.Connections.unsupportedChain
        case .walletsUnsupported:
            Localized.Errors.Connections.noSupportedWallets
        case .wrongSignParameters:
            Localized.Errors.Connections.invalidSignParameters
        case .wrongSendParameters:
            Localized.Errors.Connections.invalidSendParameters
        case .invalidOrigin,
            .maliciousOrigin:
            Localized.Errors.Connections.maliciousOrigin
        }
    }
}
