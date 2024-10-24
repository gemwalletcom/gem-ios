// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
@preconcurrency import Gemstone
import GemstonePrimitives

extension InfoSheetType {
    var url: URL? {
        switch self {
        case .networkFees: Docs.url(.networkFees)
        case .transactionStatus: Docs.url(.transactionStatus)
        }
    }
}
