// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

enum SwapQuoteInputError: Error {
    case invalidAmount
    case formatingError
    case missingFromAsset
    case missingToAsset
}
