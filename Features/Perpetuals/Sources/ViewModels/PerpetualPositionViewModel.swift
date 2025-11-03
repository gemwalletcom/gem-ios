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
        PerpetualDirectionViewModel(direction: data.position.direction).title
    }
    
    public var positionTypeText: String {
        "\(directionText.uppercased()) \(leverageText)"
    }
    
    public var positionTypeColor: Color {
        PerpetualDirectionViewModel(direction: data.position.direction).color
    }
    
    public var pnlViewModel: PnLViewModel {
        PnLViewModel(
            pnl: data.position.pnl,
            marginAmount: data.position.marginAmount,
            currencyFormatter: currencyFormatter,
            percentFormatter: percentFormatter
        )
    }
    public var pnlTitle: String { pnlViewModel.title }
    public var pnlColor: Color { pnlViewModel.color }
    public var pnlTextStyle: TextStyle { pnlViewModel.textStyle }
    public var pnlPercent: Double { pnlViewModel.percent }
    public var pnlWithPercentText: String { pnlViewModel.text ?? "" }

    public var marginTitle: String { Localized.Perpetual.margin }
    public var marginAmountText: String {
        currencyFormatter.string(data.position.marginAmount)
    }

    public var marginText: String {
        let marginAmount = currencyFormatter.string(data.position.marginAmount)
        return "\(marginAmount) (\(data.position.marginType.displayText))"
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
