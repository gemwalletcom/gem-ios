// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Localization
import GemstonePrimitives
import Primitives
import Style

public struct NoQuoteInfoSheetViewModel: InfoSheetModelViewable {
    
    public init() {}
    
    public var title: String {
        Localized.Errors.Swap.noQuoteAvailable
    }
    
    public var description: String {
        Localized.Info.NoQuote.description
    }
    
    public var image: InfoSheetImage? {
        .image(Images.Logo.logo)
    }
    
    public var button: InfoSheetButton? {
        .url(Docs.url(.noQuotes))
    }
    
    public var buttonTitle: String {
        Localized.Common.learnMore
    }
}