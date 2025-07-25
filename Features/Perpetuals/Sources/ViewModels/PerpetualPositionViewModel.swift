// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Formatters
import SwiftUI
import Style

public struct PerpetualPositionViewModel {
    public let position: PerpetualPosition
    private let currencyFormatter: CurrencyFormatter
    
    public init(
        position: PerpetualPosition,
        currencyStyle: CurrencyFormatterType = .abbreviated
    ) {
        self.position = position
        self.currencyFormatter = CurrencyFormatter(type: currencyStyle)
    }
    
    public var leverageText: String {
        "\(Int(position.leverage))x"
    }
    
    public var directionText: String {
        position.size > 0 ? "Long" : "Short"
    }
    
    public var positionTypeText: String {
        "\(directionText) \(leverageText)"
    }
    
    public var positionTypeColor: Color {
        position.size > 0 ? Colors.green : Colors.red
    }
    
    public var pnlColor: Color {
        position.pnl >= 0 ? Colors.green : Colors.red
    }
    
    public var marginAmountText: String {
        return currencyFormatter.string(position.marginAmount)
    }
    
    public var marginText: String {
        let marginAmount = currencyFormatter.string(position.marginAmount)
        return "\(marginAmount) (\(position.marginType.displayText))"
    }
    
    public var pnlText: String {
        let sign = position.pnl >= 0 ? "+" : ""
        return "\(sign)\(currencyFormatter.string(position.pnl))"
    }
    
    public var pnlPercent: Double {
        guard position.marginAmount > 0 else { return 0 }
        return (position.pnl / position.marginAmount)
    }
    
    public var pnlPercentText: String {
        CurrencyFormatter(type: .percent).string(pnlPercent)
    }
    
    public var pnlWithPercentText: String {
        let pnlAmount = currencyFormatter.string(abs(position.pnl))
        let percentFormatter = CurrencyFormatter(type: .percent)
        let percentText = percentFormatter.string(pnlPercent)
        
        if position.pnl >= 0 {
            return "+\(pnlAmount) (\(percentText))"
        } else {
            return "-\(pnlAmount) (\(percentText))"
        }
    }
    
    public var fundingPaymentsText: String {
        guard let funding = position.funding else { return "--" }
        return currencyFormatter.string(Double(funding))
    }
    
    public var fundingPaymentsColor: Color {
        guard let funding = position.funding else { return .secondary }
        return funding >= 0 ? Colors.green : Colors.red
    }
    
    public var sizeText: String {
        currencyFormatter.string(abs(position.size))
    }
    
    public var sizeValueText: String {
        currencyFormatter.string(position.sizeValue)
    }
    
    public var liquidationPriceText: String? {
        guard let price = position.liquidationPrice, price > 0 else { return .none }
        return currencyFormatter.string(price)
    }
    
    public var liquidationPriceColor: Color {
        guard position.liquidationPrice != nil else {
            return .secondary
        }
        let pnlPercent = pnlPercent
        
        switch pnlPercent {
        case ..<(-50):
            return Colors.red
        case ..<(-25):
            return Colors.orange
        default:
            return .secondary
        }
    }
}

extension PerpetualPositionViewModel: Identifiable {
    public var id: String { position.id }
}
