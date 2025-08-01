// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import InfoSheet
import Primitives
import Components

enum ConfirmTransferSheetType: Identifiable, Sendable {
    case info(InfoSheetType)
    case networkFeeSelector
    case url(URL)
    case fiatConnect(assetAddress: AssetAddress, walletId: WalletId)
    case swapDetails

    var id: String {
        switch self {
        case let .info(type): "info-\(type.id)"
        case let .url(url): "url-\(url)"
        case .networkFeeSelector: "network-fee-selector"
        case .fiatConnect: "fiat-connect"
        case .swapDetails: "swap-details"
        }
    }
}
