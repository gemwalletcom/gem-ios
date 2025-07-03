// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import InfoSheet
import Primitives
import Components

enum AmountSheetType: Identifiable, Sendable {
    case infoAction(InfoSheetType, button: InfoSheetButton)
    case fiatConnect(assetAddress: AssetAddress, walletId: WalletId)

    var id: String {
        switch self {
        case let .infoAction(type, _): "info-action-\(type.id)"
        case .fiatConnect: "fiat-connect"
        }
    }
}
