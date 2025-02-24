// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum WalletConnectorServiceError: Error {
    case unresolvedMethod(String)
    case unresolvedChainId(String)
    case walletsUnsupported
    case wrongSignParameters
    case wrongSendParameters
}

extension WalletConnectorServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unresolvedMethod(let method):
            NSLocalizedString(
                "The requested method '\(method)' is not supported.",
                comment: "Unresolved Method Error"
            )
        case .unresolvedChainId(let chainId):
            NSLocalizedString(
                "The provided chain ID '\(chainId)' is not supported.",
                comment: "Unresolved Chain ID Error"
            )
        case .walletsUnsupported:
            NSLocalizedString(
                "No supported wallets are available.",
                comment: "Unsupported Wallet Error"
            )
        case .wrongSignParameters:
            NSLocalizedString(
                "Invalid parameters provided for signing.",
                comment: "Wrong Sign Parameters Error"
            )
        case .wrongSendParameters:
            NSLocalizedString(
                "Invalid parameters provided for sending a transaction.",
                comment: "Wrong Send Parameters Error"
            )
        }
    }
}
