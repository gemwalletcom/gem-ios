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
    private let data: PerpetualConfirmData
    private let currencyFormatter = CurrencyFormatter(type: .currency, currencyCode: Currency.usd.rawValue)
    private let percentFormatter = CurrencyFormatter(type: .percent, currencyCode: Currency.usd.rawValue)
    private let percentSignLessFormatter = CurrencyFormatter.percentSignLess

    public init(data: PerpetualConfirmData) {
        self.data = data
    }

    public var listItemModel: ListItemModel {
        ListItemModel(
            title: Localized.Common.details,
            subtitle: pnlText ?? String(format: "%@ %@", directionViewModel.title, leverageText),
            subtitleStyle: pnlText == nil ? directionTextStyle : pnlTextStyle
        )
    }

    var directionTitle: String { Localized.Perpetual.direction }
    var directionViewModel: PerpetualDirectionViewModel { PerpetualDirectionViewModel(direction: data.direction) }
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
