// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Localization
import GemstonePrimitives
import Primitives
import Style
import Formatters
import BigInt

public struct InsufficientNetworkFeeInfoSheetViewModel: InfoSheetModelViewable {
    
    private let asset: Asset
    private let assetImage: AssetImage
    private let required: BigInt?
    public let button: InfoSheetButton?
    
    public init(asset: Asset, assetImage: AssetImage, required: BigInt?, button: InfoSheetButton?) {
        self.asset = asset
        self.assetImage = assetImage
        self.required = required
        self.button = button
    }
    
    public var title: String {
        Localized.Info.InsufficientNetworkFeeBalance.title(asset.symbol)
    }
    
    public var description: String {
        let text: String = {
            if let required {
                let amount = ValueFormatter(style: .full).string(required, asset: asset)
                return "**\(amount)**"
            }
            return asset.symbol
        }()
        
        return Localized.Info.InsufficientNetworkFeeBalance.description(
            text,
            asset.name,
            asset.symbol
        )
    }
    
    public var image: InfoSheetImage? {
        .assetImage(assetImage)
    }
    
    public var buttonTitle: String {
        switch button {
        case .url, .none: Localized.Common.learnMore
        case .action(let title, _): title
        }
    }
}
