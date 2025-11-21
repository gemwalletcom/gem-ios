// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization
import Primitives
import Formatters
import Components
import Style
import SwiftUI

public enum PerpetualDetailsType: Sendable {
    case open(PerpetualConfirmData)
    case close(PerpetualConfirmData)
    case increase(PerpetualConfirmData)
    case reduce(PerpetualReduceData)

    public init(_ perpetualType: PerpetualType) {
        switch perpetualType {
        case .open(let data): self = .open(data)
        case .close(let data): self = .close(data)
        case .increase(let data): self = .increase(data)
        case .reduce(let data): self = .reduce(data)
        case .modify: fatalError("not suppoerted")
        }
    }

    var data: PerpetualConfirmData {
        switch self {
        case .open(let data), .close(let data), .increase(let data): data
        case .reduce(let data): data.data
        }
    }
}

public struct PerpetualDetailsViewModel: Sendable, Identifiable {
    public var id: String { type.data.baseAsset.id.identifier }
    private let type: PerpetualDetailsType
    private let currencyFormatter = CurrencyFormatter(type: .currency, currencyCode: Currency.usd.rawValue)
    private let percentFormatter = CurrencyFormatter(type: .percent, currencyCode: Currency.usd.rawValue)
    private let percentSignLessFormatter = CurrencyFormatter.percentSignLess

    public init(type: PerpetualDetailsType) {
        self.type = type
    }

    var data: PerpetualConfirmData {
        type.data
    }

    public var listItemModel: ListItemModel {
        ListItemModel(
            title: Localized.Common.details,
            subtitle: listItemSubtitle,
            subtitleStyle: listItemSubtitleStyle
        )
    }

    var positionTitle: String { Localized.Perpetual.position }
    var positionText: String { "\(directionViewModel.title) \(leverageText)" }
    var positionTextStyle: TextStyle {
        TextStyle(font: .callout, color: directionViewModel.color)
    }

    var directionViewModel: PerpetualDirectionViewModel {
        let direction = switch type {
        case .open(let data), .close(let data), .increase(let data): data.direction
        case .reduce(let data): data.positionDirection
        }
        return PerpetualDirectionViewModel(direction: direction)
    }

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

    var sizeTitle: String { Localized.Perpetual.size }
    var sizeText: String { currencyFormatter.string(data.fiatValue) }
}

// MARK: - Private

extension PerpetualDetailsViewModel {
    private var listItemSubtitle: String? {
        switch type {
        case .open: String(format: "%@ %@", directionViewModel.title, leverageText)
        case .close: pnlText
        case .increase: directionViewModel.increaseTitle
        case .reduce: directionViewModel.reduceTitle
        }
    }

    private var listItemSubtitleStyle: TextStyle {
        switch type {
        case .open: TextStyle(font: .callout, color: directionViewModel.color)
        case .close: pnlTextStyle
        case .increase, .reduce: .calloutSecondary
        }
    }
}
