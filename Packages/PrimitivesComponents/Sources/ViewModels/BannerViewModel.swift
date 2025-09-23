// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI
import GemstonePrimitives
import Style
import Localization
import Components
import Formatters

struct BannerViewModel {
    enum BannerViewType {
        case list
        case banner
    }

    private let banner: Banner

    init(banner: Banner) {
        self.banner = banner
    }

    var image: AssetImage? {
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
        case .suspiciousAsset:
            return AssetImage.image(Images.TokenStatus.risk)
        case .buyCrypto:
            return AssetImage.image(Images.Banners.pengu)
        }
    }

    var title: String? {
        switch banner.event {
        case .stake:
            guard let asset = asset else {
                return .none
            }
            return Localized.Banner.Stake.title(asset.name)
        case .accountActivation:
            return Localized.Banner.AccountActivation.title
        case .enableNotifications: 
            return Localized.Banner.EnableNotifications.title
        case .accountBlockedMultiSignature:
            return Localized.Common.warning
        case .activateAsset:
            return Localized.Transfer.ActivateAsset.title
        case .suspiciousAsset:
            return Localized.Banner.AssetStatus.title
        case .buyCrypto: return "Welcome Aboard"
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
        case .activateAsset:
            guard let asset = asset else {
                return .none
            }
            return Localized.Banner.ActivateAsset.description(asset.symbol, asset.chain.asset.name)
        case .suspiciousAsset:
            return Localized.Banner.AssetStatus.description
        case .buyCrypto: return "Add your first crypto and start your journey"
        }
    }

    var canClose: Bool {
        banner.state != .alwaysActive
    }

    var imageSize: CGFloat {
        switch banner.event {
        case .stake,
                .accountActivation,
                .enableNotifications,
                .accountBlockedMultiSignature,
                .activateAsset,
                .suspiciousAsset: 28
        case .buyCrypto: .image.large
        }
    }

    var cornerRadius: CGFloat {
        switch banner.event {
        case .stake,
            .accountActivation,
            .activateAsset,
            .suspiciousAsset: 14
        case .enableNotifications,
            .accountBlockedMultiSignature,
            .buyCrypto: 0
        }
    }
    
    var action: BannerAction {
        BannerAction(id: banner.id, type: .event(banner.event), url: url)
    }
    
    var closeAction: BannerAction {
        BannerAction(id: banner.id, type: .closeBanner, url: nil)
    }
    
    var url: URL? {
        switch banner.event {
        case .stake,
            .enableNotifications,
            .activateAsset,
            .buyCrypto:
            return.none
        case .accountActivation:
            return asset?.chain.accountActivationFeeUrl
        case .accountBlockedMultiSignature:
            return Docs.url(.tronMultiSignature)
        case .suspiciousAsset:
            return Docs.url(.tokenVerification)
        }
    }
    
    var imageStyle: ListItemImageStyle? {
        ListItemImageStyle(
            assetImage: image,
            imageSize: imageSize,
            cornerRadiusType: .custom(cornerRadius)
        )
    }
    
    var viewType: BannerViewType {
        switch banner.event {
        case .stake,
                .accountActivation,
                .enableNotifications,
                .accountBlockedMultiSignature,
                .activateAsset,
                .suspiciousAsset: .list
        case .buyCrypto: .banner
        }
    }
    
    var buttons: [BannerButtonViewModel] {
        switch banner.event {
        case .stake,
                .accountActivation,
                .enableNotifications,
                .accountBlockedMultiSignature,
                .activateAsset,
                .suspiciousAsset: []
        case .buyCrypto: [
            BannerButtonViewModel(button: .buy, banner: banner),
            BannerButtonViewModel(button: .receive, banner: banner)
        ]
        }
    }
    
    private var asset: Asset? {
        if let asset = banner.asset {
            return asset
        }
        return banner.chain?.asset
    }
}

extension BannerViewModel: Identifiable {
    public var id: String { banner.id }
}
