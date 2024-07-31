// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum QRScannerError: Error {
    case notSupported
    case permissionsNotGranted
    case decoding
    case unknown(Error)
}
