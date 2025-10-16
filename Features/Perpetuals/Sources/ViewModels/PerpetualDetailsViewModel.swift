// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization
import Primitives
import Formatters
import PrimitivesComponents
import Components
import InfoSheet
import Style
import SwiftUI

public struct PerpetualDetailsViewModel: Sendable, Identifiable {
    public var id: String { data.baseAsset.id.identifier }
    private let data: PerpetualConfirmData
    private let currencyFormatter = CurrencyFormatter(type: .currency, currencyCode: Currency.usd.rawValue)
    private let percentFormatter = CurrencyFormatter(type: .percent, currencyCode: Currency.usd.rawValue)

    public init(data: PerpetualConfirmData) {
        self.data = data
    }

    public var listItemModel: ListItemModel {
        ListItemModel(
            title: Localized.Common.details,
            subtitle: pnlText ?? directionText,
            subtitleStyle: pnlText == nil ? TextStyle(font: .callout, color: data.direction.color) : pnlTextStyle
        )
    }

    var directionTitle: String { "Direction" }
    var directionText: String {
        switch data.direction {
        case .long: Localized.Perpetual.long
        case .short: Localized.Perpetual.short
        }
    }

    var leverageTitle: String { "Leverage" }
    var leverageText: String { "\(data.metadata.leverage)x" }

    var slippageTitle: String { Localized.Swap.slippage }
    var slippageText: String { percentFormatter.string(data.metadata.slippage) }
    
    var marketPriceTitle: String { Localized.PriceAlerts.SetAlert.currentPrice }
    var marketPriceText: String { currencyFormatter.string(data.metadata.marketPrice) }

    var entryPriceTitle: String { Localized.Perpetual.entryPrice }
    var entryPriceText: String? {
        guard let price = data.metadata.entryPrice else { return nil }
        return currencyFormatter.string(price)
    }

    var pnlViewModel: PnLViewModel {
        PnLViewModel(
            pnl: data.metadata.pnl,
            marginAmount: data.metadata.marginAmount,
            currencyFormatter: currencyFormatter,
            percentFormatter: percentFormatter
        )
    }
    var pnlTitle: String { pnlViewModel.title }
    var pnlText: String? { pnlViewModel.text }
    var pnlTextStyle: TextStyle { pnlViewModel.textStyle }

    var marginTitle: String { Localized.Perpetual.margin }
    var marginText: String { currencyFormatter.string(data.metadata.marginAmount) }
}
