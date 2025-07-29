// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Localization
import GemstonePrimitives
import Primitives
import Style

public struct NetworkFeeInfoSheetViewModel: InfoSheetModelViewable {
    
    private let chain: Chain
    
    public init(chain: Chain) {
        self.chain = chain
    }
    
    public var title: String {
        Localized.Info.NetworkFee.title
    }
    
    public var description: String {
        Localized.Info.NetworkFee.description(chain.asset.name, chain.asset.symbol)
    }
    
    public var image: InfoSheetImage? {
        .image(Images.Info.networkFee)
    }
    
    public var button: InfoSheetButton? {
        .url(Docs.url(.networkFees))
    }
    
    public var buttonTitle: String {
        Localized.Common.learnMore
    }
}