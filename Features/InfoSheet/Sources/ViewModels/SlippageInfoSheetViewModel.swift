// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Localization
import GemstonePrimitives
import Primitives
import Style

public struct SlippageInfoSheetViewModel: InfoSheetModelViewable {
    
    public init() {}
    
    public var title: String {
        Localized.Swap.slippage
    }
    
    public var description: String {
        Localized.Info.Slippage.description
    }
    
    public var image: InfoSheetImage? {
        .image(Images.Logo.logo)
    }
    
    public var button: InfoSheetButton? {
        .url(Docs.url(.slippage))
    }
    
    public var buttonTitle: String {
        Localized.Common.learnMore
    }
}