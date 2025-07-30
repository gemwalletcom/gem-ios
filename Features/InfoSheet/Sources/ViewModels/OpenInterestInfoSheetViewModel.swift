// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Localization
import GemstonePrimitives
import Primitives
import Style

public struct OpenInterestInfoSheetViewModel: InfoSheetModelViewable {
    
    public init() {}
    
    public var title: String {
        Localized.Info.OpenInterest.title
    }
    
    public var description: String {
        Localized.Info.OpenInterest.description
    }
    
    public var image: InfoSheetImage? {
        .image(Images.Logo.logo)
    }
    
    public var button: InfoSheetButton? {
        .url(Docs.url(.perpetualsOpenInterest))
    }
    
    public var buttonTitle: String {
        Localized.Common.learnMore
    }
}
