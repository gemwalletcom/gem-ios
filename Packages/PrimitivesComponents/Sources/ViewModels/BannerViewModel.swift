// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI
import GemstonePrimitives
import Style
import Localization
import Components

public struct BannerViewModel {
    public  let banner: Banner

    public init(banner: Banner) {
        self.banner = banner
    }

    public var image: AssetImage? {
        switch banner.event {
        case .stake, .accountActivation, .activateAsset:
            guard let asset = asset else {
                return .none
            }
            return AssetImage.resourceImage(image: asset.chain.rawValue)
        case .enableNotifications:
            return AssetImage.image(Images.System.bell)
        case .accountBlockedMultiSignature:
            return AssetImage.image(Images.System.exclamationmarkTriangle)
        }
    }
    
    private var asset: Asset? {
        if let asset = banner.asset {
            return asset
        }
        return banner.chain?.asset
    }

    public var title: String? {
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
        case .activateAsset:
            return Localized.Transfer.ActivateAsset.title
        }
    }

    public var description: String? {
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
        case .activateAsset:
            guard let asset = asset else {
                return .none
            }
            return Localized.Banner.ActivateAsset.description(asset.symbol, asset.chain.asset.name)
        }
    }

    public var canClose: Bool {
        banner.state != .alwaysActive
    }

    public var imageSize: CGFloat {
        28
    }

    public var cornerRadius: CGFloat {
        switch banner.event {
        case .stake,
            .accountActivation,
            .activateAsset: 14
        case .enableNotifications,
            .accountBlockedMultiSignature: 0
        }
    }
    
    public var action: BannerAction {
        BannerAction(id: banner.id, event: banner.event, url: url)
    }
    
    public var url: URL? {
        switch banner.event {
        case .stake,
            .enableNotifications,
            .activateAsset:
            return.none
        case .accountActivation:
            return asset?.chain.accountActivationFeeUrl
        case .accountBlockedMultiSignature:
            return Docs.url(.tronMultiSignature)
        }
    }
    
    public var imageStyle: AssetImageStyle? {
        AssetImageStyle(
            assetImage: image,
            imageSize: imageSize,
            overlayImageSize: .image.overlayImage.chain,
            cornerRadiusType: .custom(cornerRadius)
        )
    }
}

extension BannerViewModel: Identifiable {
    public var id: String { banner.id }
}
