// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import InfoSheet
import Primitives
import Components
import Perpetuals

enum AmountSheetType: Identifiable {
    case infoAction(InfoSheetType)
    case fiatConnect(assetAddress: AssetAddress, walletId: WalletId)
    case leverageSelector(title: String, selection: LeverageSelection)
    case autoclose(AutocloseOpenData)

    var id: String {
        switch self {
        case let .infoAction(type): "info-action-\(type.id)"
        case .fiatConnect: "fiat-connect"
        case .leverageSelector: "leverage-selector"
        case .autoclose: "autoclose"
        }
    }
}
