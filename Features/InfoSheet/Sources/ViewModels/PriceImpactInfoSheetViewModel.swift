// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Localization
import GemstonePrimitives
import Primitives
import Style

public struct PriceImpactInfoSheetViewModel: InfoSheetModelViewable {
    
    public init() {}
    
    public var title: String {
        Localized.Info.PriceImpact.title
    }
    
    public var description: String {
        Localized.Info.PriceImpact.description
    }
    
    public var image: InfoSheetImage? {
        .image(Images.Logo.logo)
    }
    
    public var button: InfoSheetButton? {
        .url(Docs.url(.priceImpact))
    }
    
    public var buttonTitle: String {
        Localized.Common.learnMore
    }
}