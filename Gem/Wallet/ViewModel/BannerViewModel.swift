// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI
import GemstonePrimitives
import Style
import Localization

struct BannerViewModel {

    let banner: Banner

    var image: Image? {
        switch banner.event {
        case .stake, .accountActivation:
            guard let asset = banner.asset else {
                return .none
            }
            return Image(uiImage: UIImage(imageLiteralResourceName: asset.chain.rawValue))
        case .enableNotifications:
            return Image(systemName: SystemImage.bell)
        }
    }

    var title: String? {
        switch banner.event {
        case .stake:
            guard let asset = banner.asset else {
                return .none
            }
            return Localized.Banner.Stake.title(asset.name)
        case .accountActivation:
            guard let asset = banner.asset else {
                return .none
            }
            return Localized.Banner.AccountActivation.title(asset.name)
        case .enableNotifications: 
            return Localized.Banner.EnableNotifications.title
        }
    }

    var description: String? {
        switch banner.event {
        case .stake:
            guard let asset = banner.asset else {
                return .none
            }
            return Localized.Banner.Stake.description(asset.symbol)
        case .accountActivation:
            guard let asset = banner.asset, let fee = asset.chain.accountActivationFee else {
                return .none
            }
            let amount = ValueFormatter(style: .full)
                .string(fee.asInt.asBigInt, decimals: asset.decimals.asInt, currency: asset.symbol)
            return Localized.Banner.AccountActivation.description(asset.name, amount)
        case .enableNotifications: 
            return Localized.Banner.EnableNotifications.description
        }
    }

    var canClose: Bool {
        banner.state != .alwaysActive
    }
}

extension BannerViewModel: Identifiable {
    var id: String { banner.id }
}
