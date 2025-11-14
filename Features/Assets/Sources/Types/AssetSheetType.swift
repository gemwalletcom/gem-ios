// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import InfoSheet
import Primitives

public enum AssetSheetType: Identifiable, Sendable {
    case info(InfoSheetType)
    case transfer(ConfirmTransferPresentation)
    case share
    case url(URL)

    public var id: String {
        switch self {
        case let .info(type): "info-\(type.id)"
        case let .transfer(presentation): "transfer-\(presentation.id)"
        case .share: "share"
        case let .url(url): "url-\(url)"
        }
    }
}
