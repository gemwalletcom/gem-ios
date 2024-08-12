// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI
import GemstonePrimitives

struct BannerViewModel {

    let banner: Banner

    var image: Image {
        //TODO: Fix images
        switch banner.event {
        case .stake: Image(.aptos)
        case .accountActivation: Image(.aptos)
        }
    }

    var title: String? {
        switch banner.event {
        case .stake: "Start Staking"
        case .accountActivation: "Test"
        }
    }

    var description: String? {
        guard let asset = banner.asset else {
            return .none
        }
        //TODO: Add string to localize
        switch banner.event {
        case .stake:
            return String(format: "Start earning on your %@", asset.name)
        case .accountActivation:
            guard let fee = asset.chain.accountActivationFee else {
                return .none
            }
            let amount = ValueFormatter(style: .full).string(fee.asInt.asBigInt, decimals: asset.decimals.asInt)
            return String(format: "The %@ network requires a one time fee of %@ %@", asset.name, amount, asset.symbol)
        }
    }

    var canClose: Bool {
        banner.state != .alwaysActive
    }
}
