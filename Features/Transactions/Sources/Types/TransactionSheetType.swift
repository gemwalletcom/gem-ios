// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import InfoSheet

enum TransactionSheetType: Identifiable {
    case share
    case feeDetails
    case info(InfoSheetType)

    var id: String {
        switch self {
        case .share: "share"
        case .feeDetails: "feeDetails"
        case .info(let type): "info_\(type.id)"
        }
    }
}
