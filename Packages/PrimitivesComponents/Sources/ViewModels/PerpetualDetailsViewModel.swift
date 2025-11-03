// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization
import Primitives
import Formatters
import Components
import Style
import SwiftUI

public struct PerpetualDetailsViewModel: Sendable, Identifiable {
    public var id: String { data.baseAsset.id.identifier }
    private let perpetualType: PerpetualType
    private let currencyFormatter = CurrencyFormatter(type: .currency, currencyCode: Currency.usd.rawValue)
    private let percentFormatter = CurrencyFormatter(type: .percent, currencyCode: Currency.usd.rawValue)
    private let percentSignLessFormatter = CurrencyFormatter.percentSignLess

    public init(perpetualType: PerpetualType) {
        self.perpetualType = perpetualType
    }
    
    var data: PerpetualConfirmData { perpetualType.data }

    public var listItemModel: ListItemModel {
        ListItemModel(
            title: Localized.Common.details,
            subtitle: listItemSubtitle,
            subtitleStyle: listItemSubtitleStyle
        )
    }

    var directionTitle: String {
        switch perpetualType {
        case .open: Localized.Perpetual.direction
        case .close, .increase, .reduce: Localized.Perpetual.position
        }
    }
    var directionViewModel: PerpetualDirectionViewModel {
        switch perpetualType {
        case .open, .close, .increase: PerpetualDirectionViewModel(direction: perpetualType.data.direction)
        case .reduce(let reduceData): PerpetualDirectionViewModel(direction: reduceData.positionDirection)
        }
    }
    var directionTextStyle: TextStyle { TextStyle(font: .callout, color: directionViewModel.color) }

    var leverageTitle: String { Localized.Perpetual.leverage}
    var leverageText: String { "\(data.leverage)x" }

    var slippageTitle: String { Localized.Swap.slippage }
    var slippageText: String { percentSignLessFormatter.string(data.slippage) }

    var marketPriceTitle: String { Localized.PriceAlerts.SetAlert.currentPrice }
    var marketPriceText: String { currencyFormatter.string(data.marketPrice) }

    var entryPriceTitle: String { Localized.Perpetual.entryPrice }
    var entryPriceText: String? {
        guard let price = data.entryPrice else { return nil }
        return currencyFormatter.string(price)
    }

    var pnlViewModel: PnLViewModel {
        PnLViewModel(
            pnl: data.pnl,
            marginAmount: data.marginAmount,
            currencyFormatter: currencyFormatter,
            percentFormatter: percentFormatter
        )
    }
    var pnlTitle: String { pnlViewModel.title }
    var pnlText: String? { pnlViewModel.text }
    var pnlTextStyle: TextStyle { pnlViewModel.textStyle }

    var marginTitle: String { Localized.Perpetual.margin }
    var marginText: String { currencyFormatter.string(data.marginAmount) }
}

// MARK: - Private

extension PerpetualDetailsViewModel {
    private var listItemSubtitle: String? {
        switch perpetualType {
        case .open: String(format: "%@ %@", directionViewModel.title, leverageText)
        case .close(_): pnlText
        case .increase(_): directionViewModel.increaseTitle
        case .reduce: directionViewModel.reduceTitle
        }
    }
    
    private var listItemSubtitleStyle: TextStyle {
        switch perpetualType {
        case .open: TextStyle(font: .callout, color: directionViewModel.color)
        case .close: pnlTextStyle
        case .increase, .reduce: .calloutSecondary
        }
    }
}
