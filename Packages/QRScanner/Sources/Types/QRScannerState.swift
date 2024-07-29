// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

enum QRScannerState {
    case idle
    case failure(error: QRScannerError)
    case scanning
}
