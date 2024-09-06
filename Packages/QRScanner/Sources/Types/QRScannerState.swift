// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

enum QRScannerState {
    case idle
    case failure(error: QRScannerError)
    case scanning
}

extension QRScannerState: Equatable {
    static func == (lhs: QRScannerState, rhs: QRScannerState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.scanning, .scanning):
            return true
        case (.failure(let lhsError), .failure(let rhsError)):
            return true //TODO: lhsError == rhsError
        default:
            return false
        }
    }
}
