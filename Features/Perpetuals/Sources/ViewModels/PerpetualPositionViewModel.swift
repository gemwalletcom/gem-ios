// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Formatters
import SwiftUI
import Style
import Components
import PrimitivesComponents

public struct PerpetualPositionViewModel {
    public let data: PerpetualPositionData
    private let currencyFormatter: CurrencyFormatter
    
    public init(
        data: PerpetualPositionData,
        currencyStyle: CurrencyFormatterType = .abbreviated
    ) {
        self.data = data
        self.currencyFormatter = CurrencyFormatter(type: currencyStyle)
    }
    
    public var assetImage: AssetImage {
        AssetIdViewModel(assetId: data.perpetual.assetId).assetImage
    }
    
    public var nameText: String {
        data.asset.name
    }
    
    public var symbolText: String {
        data.asset.symbol
    }
    
    public var leverageText: String {
        "\(Int(data.position.leverage))x"
    }
    
    public var directionText: String {
        switch data.position.direction {
        case .short: "Short"
        case .long: "Long"
        }
    }
    
    public var positionTypeText: String {
        "\(directionText) \(leverageText)"
    }
    
    public var positionTypeColor: Color {
        data.position.size > 0 ? Colors.green : Colors.red
    }
    
    public var pnlColor: Color {
        data.position.pnl >= 0 ? Colors.green : Colors.red
    }
    
    public var marginAmountText: String {
        return currencyFormatter.string(data.position.marginAmount)
    }
    
    public var marginText: String {
        let marginAmount = currencyFormatter.string(data.position.marginAmount)
        return "\(marginAmount) (\(data.position.marginType.displayText))"
    }
    
    public var pnlText: String {
        let sign = data.position.pnl >= 0 ? "+" : ""
        return "\(sign)\(currencyFormatter.string(data.position.pnl))"
    }
    
    public var pnlPercent: Double {
        guard data.position.marginAmount > 0 else { return 0 }
        return (data.position.pnl / data.position.marginAmount)
    }
    
    public var pnlPercentText: String {
        CurrencyFormatter(type: .percent).string(pnlPercent)
    }
    
    public var pnlWithPercentText: String {
        let pnlAmount = currencyFormatter.string(abs(data.position.pnl))
        let percentFormatter = CurrencyFormatter(type: .percent)
        let percentText = percentFormatter.string(pnlPercent)
        
        if data.position.pnl >= 0 {
            return "+\(pnlAmount) (\(percentText))"
        } else {
            return "-\(pnlAmount) (\(percentText))"
        }
    }
    
    public var fundingPaymentsText: String {
        guard let funding = data.position.funding else { return "--" }
        return currencyFormatter.string(Double(funding))
    }
    
    public var fundingPaymentsColor: Color {
        guard let funding = data.position.funding else { return .secondary }
        return funding >= 0 ? Colors.green : Colors.red
    }
    
    public var sizeText: String {
        currencyFormatter.string(abs(data.position.size))
    }
    
    public var sizeValueText: String {
        currencyFormatter.string(data.position.sizeValue)
    }
    
    public var liquidationPriceText: String? {
        guard let price = data.position.liquidationPrice, price > 0 else { return .none }
        return currencyFormatter.string(price)
    }
    
    public var liquidationPriceColor: Color {
        guard data.position.liquidationPrice != nil else {
            return .secondary
        }
        let pnlPercent = pnlPercent
        
        switch pnlPercent {
        case ..<(-0.50):
            return Colors.red
        case ..<(-0.25):
            return Colors.orange
        default:
            return .secondary
        }
    }
}

extension PerpetualPositionViewModel: Identifiable {
    public var id: String { data.position.id }
}

extension PerpetualMarginType {
    var displayText: String {
        switch self {
        case .cross:
            return "cross"
        case .isolated:
            return "isolated"
        }
    }
}
