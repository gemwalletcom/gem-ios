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
    private let asset: Asset
    private let data: PerpetualConfirmData
    private let currencyFormatter = CurrencyFormatter(type: .currency, currencyCode: Currency.usd.rawValue)

    public init(asset: Asset, data: PerpetualConfirmData) {
        self.asset = asset
        self.data = data
    }

    public var listItemModel: ListItemModel {
        ListItemModel(
            title: Localized.Common.details,
            subtitle: directionText,
            subtitleStyle: TextStyle(font: .callout, color: positionColor)
        )
    }
    var positionColor: Color {
        switch data.direction {
        case .short: Colors.red
        case .long: Colors.green
        }
    }

    var sizeTitle: String { Localized.Perpetual.size }
    var sizeText: String {
        guard let size = Double(data.size) else { return data.size }
        return currencyFormatter.string(double: size, symbol: asset.symbol)
    }

    var executionPriceTitle: String {
        switch data.direction {
        case .long: "Max Execution Price"
        case .short: "Min Execution Price"
        }
    }
    var executionPriceText: String {
        guard let price = Double(data.price) else { return data.price }
        return currencyFormatter.string(price)
    }

    var directionTitle: String { "Direction" }
    var directionText: String {
        switch data.direction {
        case .long: Localized.Perpetual.long
        case .short: Localized.Perpetual.short
        }
    }

    var notionalValueTitle: String { "Position Value" }
    var notionalValueText: String {
        currencyFormatter.string(data.fiatValue)
    }
}
