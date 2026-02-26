// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import WalletCore

public extension Chain {

    var defaultKeyEncodingType: EncodingType {
        keyEncodingTypes.first!
    }

    var keyEncodingTypes: [EncodingType] {
        //TODO: Use chain type in the future
        switch self {
        case .solana:
            [.base58, .hex]
        case .bitcoin, .litecoin, .doge, .bitcoinCash:
            [.base58, .hex]
        case .stellar:
            [.base32, .hex]
        default:
            [.hex]
        }
    }
}
