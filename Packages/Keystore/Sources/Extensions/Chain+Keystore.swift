// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import WalletCore
import WalletCorePrimitives

public extension Chain {

    var defaultKeyEncodingType: EncodingType {
        keyEncodingTypes.first!
    }

    var keyEncodingTypes: [EncodingType] {
        //TODO: Use chain type in the future
        switch self {
        case .solana:
            [.base58, .hex]
        default:
            [.hex]
        }
    }
}
