// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public enum TokenValidationError: Error {
    case invalidTokenId
    case invalidMetadata
    case other(Error)
}

public enum ChainServiceErrors: Error {
    case broadcastError(Chain)
}
