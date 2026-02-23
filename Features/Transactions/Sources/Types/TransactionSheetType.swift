// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import InfoSheet
import Contacts

enum TransactionSheetType: Identifiable {
    case share
    case feeDetails
    case info(InfoSheetType)
    case addContact(AddAddressInput)

    var id: String {
        switch self {
        case .share: "share"
        case .feeDetails: "feeDetails"
        case .info(let type): "info_\(type.id)"
        case .addContact(let input): "addContact_\(input.chain.rawValue)_\(input.address)"
        }
    }
}
