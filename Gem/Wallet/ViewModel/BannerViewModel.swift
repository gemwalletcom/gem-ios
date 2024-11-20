// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI
import GemstonePrimitives
import Style
import Localization
import struct BannerService.BannerAction

struct BannerViewModel {

    let banner: Banner

    var image: Image? {
        switch banner.event {
        case .stake, .accountActivation:
            guard let asset = asset else {
                return .none
            }
            return Images.name(asset.chain.rawValue)
        case .enableNotifications:
            return Images.System.bell
        case .accountBlockedMultiSignature:
            return Images.System.exclamationmarkTriangle
        }
    }
    
    private var asset: Asset? {
        if let asset = banner.asset {
            return asset
        }
        return banner.chain?.asset
    }

    var title: String? {
        switch banner.event {
        case .stake:
            guard let asset = asset else {
                return .none
            }
            return Localized.Banner.Stake.title(asset.name)
        case .accountActivation:
            guard let asset = asset else {
                return .none
            }
            return Localized.Banner.AccountActivation.title(asset.name)
        case .enableNotifications: 
            return Localized.Banner.EnableNotifications.title
        case .accountBlockedMultiSignature:
            return Localized.Common.warning
        }
    }

    var description: String? {
        switch banner.event {
        case .stake:
            guard let asset = asset else {
                return .none
            }
            return Localized.Banner.Stake.description(asset.symbol)
        case .accountActivation:
            guard let asset = asset, let fee = asset.chain.accountActivationFee else {
                return .none
            }
            let amount = ValueFormatter(style: .full)
                .string(fee.asInt.asBigInt, decimals: asset.decimals.asInt, currency: asset.symbol)
            return Localized.Banner.AccountActivation.description(asset.name, amount)
        case .enableNotifications: 
            return Localized.Banner.EnableNotifications.description
        case .accountBlockedMultiSignature:
            return Localized.Warnings.multiSignatureBlocked(asset?.name ?? "")
        }
    }

    var canClose: Bool {
        banner.state != .alwaysActive
    }

    var imageSize: CGFloat {
        28
    }

    var cornerRadius: CGFloat {
        switch banner.event {
        case .stake,
            .accountActivation: 14
        case .enableNotifications,
            .accountBlockedMultiSignature: 0
        }
    }
    
    var action: BannerAction {
        BannerAction(id: banner.id, event: banner.event, url: url)
    }
    
    var url: URL? {
        switch banner.event {
        case .stake,
            .enableNotifications:
            return.none
        case .accountActivation:
            return URL(string: "https://xrpl.org/reserves.html")!
        case .accountBlockedMultiSignature:
            return Docs.url(.tronMultiSignature)
        }
    }
}

extension BannerViewModel: Identifiable {
    var id: String { banner.id }
}
