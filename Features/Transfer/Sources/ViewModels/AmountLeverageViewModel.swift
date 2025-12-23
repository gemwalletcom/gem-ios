// Copyright (c). Gem Wallet. All rights reserved.

import Components
import Foundation
import Localization
import Perpetuals
import Preferences
import Primitives
import PrimitivesComponents
import Style

struct AmountLeverageViewModel {
    private let type: AmountType
    private let selectedLeverage: LeverageOption

    init(type: AmountType, selectedLeverage: LeverageOption) {
        self.type = type
        self.selectedLeverage = selectedLeverage
    }

    var showLeverage: Bool {
        switch type {
        case .perpetual(let data):
            switch data.positionAction {
            case .open: true
            case .increase, .reduce: false
            }
        case .transfer, .deposit, .withdraw, .stake, .stakeRedelegate, .stakeUnstake, .stakeWithdraw, .freeze: false
        }
    }

    var maxLeverage: UInt8 {
        switch type {
        case .perpetual(let data): data.positionAction.transferData.leverage
        case .transfer, .deposit, .withdraw, .stake, .stakeRedelegate, .stakeUnstake, .stakeWithdraw, .freeze: .zero
        }
    }

    var leverageOptions: [LeverageOption] {
        LeverageOption.allOptions.filter { $0.value <= maxLeverage }
    }

    var text: String { selectedLeverage.displayText }

    var textStyle: TextStyle {
        guard case .perpetual(let data) = type,
              case .open(let transferData) = data.positionAction
        else {
            return .callout
        }
        return TextStyle(
            font: .callout,
            color: PerpetualDirectionViewModel(direction: transferData.direction).color
        )
    }

    static func defaultLeverage(for type: AmountType) -> LeverageOption {
        guard case .perpetual(let data) = type else {
            return LeverageOption(value: 1)
        }
        let maxLeverage = data.positionAction.transferData.leverage
        let options = LeverageOption.allOptions.filter { $0.value <= maxLeverage }
        switch data.positionAction {
        case .open:
            return LeverageOption.option(
                desiredValue: Preferences.standard.perpetualLeverage,
                from: options
            )
        case .increase, .reduce:
            return LeverageOption(value: maxLeverage)
        }
    }
}

// MARK: - ItemModelProvidable

extension AmountLeverageViewModel: ItemModelProvidable {
    var itemModel: AmountItemModel {
        guard showLeverage else { return .empty }
        return .leverage(
            ListItemModel(
                title: Localized.Perpetual.leverage,
                subtitle: text,
                subtitleStyle: textStyle
            )
        )
    }
}
