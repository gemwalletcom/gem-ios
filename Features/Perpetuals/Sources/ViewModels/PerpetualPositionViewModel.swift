// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Formatters
import SwiftUI
import Style
import Components
import PrimitivesComponents
import Localization

public struct PerpetualPositionViewModel {
    public let data: PerpetualPositionData
    private let currencyFormatter: CurrencyFormatter
    private let percentFormatter: CurrencyFormatter
    
    public init(
        _ data: PerpetualPositionData,
        currencyStyle: CurrencyFormatterType = .currency
    ) {
        self.data = data
        self.currencyFormatter = CurrencyFormatter(type: currencyStyle, currencyCode: Currency.usd.rawValue)
        self.percentFormatter = CurrencyFormatter(type: .percent, currencyCode: Currency.usd.rawValue)
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
        case .short: Localized.Perpetual.short
        case .long: Localized.Perpetual.long
        }
    }
    
    public var positionTypeText: String {
        "\(directionText.uppercased()) \(leverageText)"
    }
    
    public var positionTypeColor: Color {
        switch data.position.direction {
        case .short: Colors.red
        case .long: Colors.green
        }
    }
    
    public var pnlTitle: String { Localized.Perpetual.pnl }
    public var pnlColor: Color {
        PriceChangeColor.color(for: data.position.pnl)
    }
    
    public var pnlTextStyle: TextStyle {
        TextStyle(font: .callout, color: pnlColor)
    }
    
    public var marginTitle: String { Localized.Perpetual.margin }
    public var marginAmountText: String {
        currencyFormatter.string(data.position.marginAmount)
    }

    var autocloseTitle: String { "Auto close" }
    var autocloseText: String {
        "TP: \(data.position.takeProfit.map { currencyFormatter.string($0.price) } ?? "-")"
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
        return (data.position.pnl / data.position.marginAmount) * 100
    }
    
    public var pnlPercentText: String {
        percentFormatter.string(pnlPercent)
    }
    
    public var pnlWithPercentText: String {
        let pnlAmount = currencyFormatter.string(abs(data.position.pnl))
        let percentText = percentFormatter.string(pnlPercent)
        
        if data.position.pnl >= 0 {
            return "+\(pnlAmount) (\(percentText))"
        } else {
            return "-\(pnlAmount) (\(percentText))"
        }
    }
    
    public var fundingPaymentsTitle: String { Localized.Info.FundingPayments.title }
    public var fundingPaymentsText: String {
        guard let funding = data.position.funding else { return "--" }
        return currencyFormatter.string(Double(funding))
    }
    public var fundingPaymentsColor: Color {
        guard let funding = data.position.funding else { return .secondary }
        return PriceChangeColor.color(for: Double(funding))
    }
    
    public var fundingPaymentsTextStyle: TextStyle {
        TextStyle(font: .callout, color: fundingPaymentsColor)
    }
    
    public var sizeTitle: String { Localized.Perpetual.size }
    public var sizeValueText: String {
        currencyFormatter.string(data.position.sizeValue)
    }
    
    public var entryPriceTitle: String { Localized.Perpetual.entryPrice }
    public var entryPriceText: String? {
        guard let price = data.position.entryPrice, price > 0 else { return .none }
        return currencyFormatter.string(price)
    }
    
    public var liquidationPriceTitle: String { Localized.Info.LiquidationPrice.title }
    public var liquidationPriceText: String? {
        guard let price = data.position.liquidationPrice, price > 0 else { return .none }
        return currencyFormatter.string(price)
    }
    
    public var liquidationPriceColor: Color {
//        guard let entryPrice = data.position.entryPrice,
//              let liquidationPrice = data.position.liquidationPrice,
//              let currentPrice = data.position.currencyPrice,
//              entryPrice > 0, liquidationPrice > 0, currentPrice > 0 else {
//            return Colors.secondaryText
//        }
//        
//        let priceRange = abs(entryPrice - liquidationPrice)
//        let distance = abs(currentPrice - entryPrice)
//        let progress = distance / priceRange
//        
//        return switch progress {
//        case 0.8...: Colors.red
//        case 0.5..<0.8: Colors.orange
//        default: Colors.secondaryText
//        }
        Colors.secondaryText
    }
    
    public var liquidationPriceTextStyle: TextStyle {
        TextStyle(font: .callout, color: liquidationPriceColor)
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
