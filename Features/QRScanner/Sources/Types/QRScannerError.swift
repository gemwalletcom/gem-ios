// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

enum QRScannerError: Error, Sendable {
    case notSupported
    case permissionsNotGranted
    case decoding
    case unknown(Error)
}

extension QRScannerError: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.notSupported, .notSupported),
            (.permissionsNotGranted, .permissionsNotGranted),
            (.decoding, .decoding):
            return true
        case (.unknown, .unknown):
            return true
        default:
            return false
        }
    }
}
