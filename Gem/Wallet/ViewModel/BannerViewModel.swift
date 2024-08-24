// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI
import GemstonePrimitives

struct BannerViewModel {

    let banner: Banner

    var image: Image? {
        switch banner.event {
        case .stake, .accountActivation:
            guard let asset = banner.asset else {
                return .none
            }
            return Image(uiImage: UIImage(imageLiteralResourceName: asset.chain.rawValue))
        }
    }

    var title: String? {
        guard let asset = banner.asset else {
            return .none
        }
        return switch banner.event {
        case .stake: Localized.Banner.Staking.title(asset.name)
        case .accountActivation: Localized.Banner.AccountActivation.title(asset.name)
        }
    }

    var description: String? {
        guard let asset = banner.asset else {
            return .none
        }
        switch banner.event {
        case .stake:
            return Localized.Banner.Staking.description(asset.symbol)
        case .accountActivation:
            guard let fee = asset.chain.accountActivationFee else {
                return .none
            }
            let amount = ValueFormatter(style: .full)
                .string(fee.asInt.asBigInt, decimals: asset.decimals.asInt, currency: asset.symbol)
            return Localized.Banner.AccountActivation.description(asset.name, amount)
        }
    }

    var canClose: Bool {
        banner.state != .alwaysActive
    }
}

extension BannerViewModel: Identifiable {
    var id: String { banner.id }
}
