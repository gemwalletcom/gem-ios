// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import InfoSheet

public enum SwapSheetType: Identifiable, Equatable, Sendable {
    case info(InfoSheetType)
    case selectAsset(SelectAssetSwapType)
    case swapProvider(AssetData)

    public var id: String {
        switch self {
        case let .info(type): "info-\(type)"
        case let .selectAsset(type): "selectAsset-\(type)"
        case let .swapProvider(asset): "provider-\(asset.id)"
        }
    }
}
