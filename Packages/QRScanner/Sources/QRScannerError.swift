// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

enum QRScannerError: Error {
    case notSupported
    case permissionsNotGranted
    case decoding
    case unexpected(Error)

    func localizedDescription(using provider: QRScannerTextProviding) -> String {
        switch self {
        case .notSupported:
            return provider.errorNotSupported
        case .permissionsNotGranted:
            return provider.errorPermissionsNotGranted
        case .decoding:
            return provider.errorDecoding
        case .unexpected:
            return provider.errorUnexpected
        }
    }
}
