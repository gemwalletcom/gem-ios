// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Localization
import GemstonePrimitives
import Primitives
import Style

public struct InsufficientBalanceInfoSheetViewModel: InfoSheetModelViewable {
    
    private let asset: Asset
    private let assetImage: AssetImage
    public let button: InfoSheetButton?
    
    public init(asset: Asset, assetImage: AssetImage, button: InfoSheetButton?) {
        self.asset = asset
        self.assetImage = assetImage
        self.button = button
    }
    
    public var title: String {
        Localized.Info.InsufficientBalance.title
    }
    
    public var description: String {
        Localized.Info.InsufficientBalance.description(asset.symbol)
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
