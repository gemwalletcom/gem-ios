// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import InfoSheet
import Primitives

enum AssetSheetType: Identifiable, Sendable {
    case info(InfoSheetType)
    case transfer(TransferData)
    case share
    case setPriceAlert
    case url(URL)

    var id: String {
        switch self {
        case let .info(type): "info-\(type.id)"
        case let .transfer(data): "transfer-\(data.id)"
        case .share: "share"
        case .setPriceAlert: "priceAlert"
        case let .url(url): "url-\(url)"
        }
    }
}
