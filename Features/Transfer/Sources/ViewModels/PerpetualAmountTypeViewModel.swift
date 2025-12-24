// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Formatters
import Localization
import Preferences
import Primitives
import PrimitivesComponents
import Style

@Observable
public final class PerpetualAmountTypeViewModel: AmountTypeConfigurable {
    public typealias Item = LeverageOption
    public typealias ItemViewModel = LeverageOption

    private let positionAction: PerpetualPositionAction
    private let currencyFormatter: CurrencyFormatter
    private let autocloseFormatter: AutocloseFormatter

    public var selectedItem: LeverageOption?
    public var takeProfit: String?
    public var stopLoss: String?

    public init(
        positionAction: PerpetualPositionAction,
        currencyFormatter: CurrencyFormatter = CurrencyFormatter(type: .currency, currencyCode: Preferences.standard.currency),
        autocloseFormatter: AutocloseFormatter = AutocloseFormatter()
    ) {
        self.positionAction = positionAction
        self.currencyFormatter = currencyFormatter
        self.autocloseFormatter = autocloseFormatter
        self.selectedItem = defaultItem
    }

    public var items: [LeverageOption] {
        LeverageOption.allOptions.filter { $0.value <= maxLeverage }
    }

    public var defaultItem: LeverageOption? {
        switch positionAction {
        case .open:
            LeverageOption.option(
                desiredValue: Preferences.standard.perpetualLeverage,
                from: items
            )
        case .increase(let data):
            LeverageOption(value: data.leverage)
        case .reduce(let data, _, _):
            LeverageOption(value: data.leverage)
        }
    }

    public var selectedItemViewModel: LeverageOption? { selectedItem }

    public var isSelectionEnabled: Bool {
        switch positionAction {
        case .open: true
        case .increase, .reduce: false
        }
    }

    public var selectionTitle: String { Localized.Perpetual.leverage }

    public var maxLeverage: UInt8 {
        positionAction.transferData.leverage
    }

    public var leverageText: String {
        selectedItem?.displayText ?? ""
    }

    public var leverageTextStyle: TextStyle {
        guard case .open(let transferData) = positionAction else {
            return .callout
        }
        return TextStyle(
            font: .callout,
            color: PerpetualDirectionViewModel(direction: transferData.direction).color
        )
    }

    public var isAutocloseEnabled: Bool {
        switch positionAction {
        case .open: true
        case .increase, .reduce: false
        }
    }

    public var autocloseTitle: String { Localized.Perpetual.autoClose }

    public var autocloseText: (subtitle: String, subtitleExtra: String?) {
        autocloseFormatter.format(
            takeProfit: takeProfit.flatMap { currencyFormatter.double(from: $0) },
            stopLoss: stopLoss.flatMap { currencyFormatter.double(from: $0) }
        )
    }

    public var transferData: PerpetualTransferData {
        positionAction.transferData
    }
}
