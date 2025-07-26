// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import PrimitivesComponents
import Formatters
import Components

public struct PerpetualViewModel {
    public let perpetual: Perpetual
    private let currencyFormatter: CurrencyFormatter
    private let fundingRateFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 5
        return formatter
    }()
    
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
    
    public var volumeTitle: String { "24h Volume" }
    public var volumeText: String {
        currencyFormatter.string(perpetual.volume24h)
    }
    
    public var openInterestTitle: String { "Open Interest" }
    public var openInterestText: String {
        currencyFormatter.string(perpetual.openInterest)
    }
    
    public var fundingRateTitle: String { "Funding Rate" }
    public var fundingRateText: String {
        if let formattedNumber = fundingRateFormatter.string(from: NSNumber(value: perpetual.funding)) {
            return "\(formattedNumber)%"
        }
        return CurrencyFormatter(type: .percent).string(perpetual.funding)
    }
    
    public var priceText: String {
        currencyFormatter.string(perpetual.price)
    }
}
