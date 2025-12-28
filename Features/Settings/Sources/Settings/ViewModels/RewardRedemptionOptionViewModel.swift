// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt
import Primitives
import Components
import PrimitivesComponents
import Formatters
import Localization

struct RewardRedemptionOptionViewModel: Identifiable {
    let option: RewardRedemptionOption

    var id: String { option.id }

    var title: String {
        switch option.redemptionType {
        case .asset, .giftAsset:
            return Localized.Rewards.WaysSpend.Asset.title(valueText)
        }
    }

    var subtitle: String {
        pointsText
    }

    var assetImage: AssetImage {
        guard let asset = option.asset else {
            return AssetImage()
        }
        return AssetIdViewModel(assetId: asset.id).assetImage
    }

    var pointsText: String {
        "\(option.points) 💎"
    }

    var valueText: String {
        switch option.redemptionType {
        case .asset, .giftAsset:
            guard let asset = option.asset else { return option.value }
            let value = BigInt(stringLiteral: option.value)
            return ValueFormatter.compact.string(value, asset: asset)
        }
    }

    var confirmationMessage: String {
        Localized.Rewards.confirmRedeem(title, pointsText)
    }
}
