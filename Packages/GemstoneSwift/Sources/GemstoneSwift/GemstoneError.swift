// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemstoneError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .AnyError(let msg):
            return msg
        }
    }
}
