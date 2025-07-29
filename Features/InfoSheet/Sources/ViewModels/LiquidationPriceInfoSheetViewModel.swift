// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Localization
import GemstonePrimitives
import Primitives
import Style

public struct LiquidationPriceInfoSheetViewModel: InfoSheetModelViewable {
    
    public init() {}
    
    public var title: String {
        Localized.Info.LiquidationPrice.title
    }
    
    public var description: String {
        Localized.Info.LiquidationPrice.description
    }
    
    public var image: InfoSheetImage? {
        .image(Images.Logo.logo)
    }
    
    public var button: InfoSheetButton? {
        .url(Docs.url(.networkFees))
    }
    
    public var buttonTitle: String {
        Localized.Common.learnMore
    }
}