// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PrimitivesComponents
import Formatters
import Components

public struct PerpetualViewModel {
    public let perpetual: Perpetual
    private let currencyFormatter: CurrencyFormatter
    
    public init(perpetual: Perpetual, currencyStyle: CurrencyFormatterType = .abbreviated) {
        self.perpetual = perpetual
        self.currencyFormatter = CurrencyFormatter(type: currencyStyle)
    }
    
    public var name: String {
        perpetual.name
    }
    
    public var assetImage: AssetImage {
        AssetIdViewModel(assetId: perpetual.assetId).assetImage
    }
    
    public var volumeText: String {
        currencyFormatter.string(perpetual.volume24h)
    }
    
    public var openInterestText: String {
        currencyFormatter.string(perpetual.openInterest)
    }
    
    public var fundingRateText: String {
        return CurrencyFormatter(type: .percent).string(perpetual.funding)
    }
    
    public var priceText: String {
        currencyFormatter.string(perpetual.price)
    }
}
