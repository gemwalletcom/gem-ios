// Copyright (c). Gem Wallet. All rights reserved.

import Components
import Formatters
import Foundation
import Localization
import Primitives

struct AmountAutocloseViewModel {
    private let type: AmountType
    private let takeProfit: Double?
    private let stopLoss: Double?
    private let formatter: AutocloseFormatter

    init(
        type: AmountType,
        takeProfit: Double?,
        stopLoss: Double?,
        formatter: AutocloseFormatter = AutocloseFormatter()
    ) {
        self.type = type
        self.takeProfit = takeProfit
        self.stopLoss = stopLoss
        self.formatter = formatter
    }

    var showAutoclose: Bool {
        switch type {
        case .perpetual(let data):
            switch data.positionAction {
            case .open: true
            case .increase, .reduce: false
            }
        case .transfer, .deposit, .withdraw, .stake, .stakeRedelegate, .stakeUnstake, .stakeWithdraw, .freeze: false
        }
    }

    var text: (subtitle: String, subtitleExtra: String?) {
        formatter.format(takeProfit: takeProfit, stopLoss: stopLoss)
    }
}

// MARK: - ItemModelProvidable

extension AmountAutocloseViewModel: ItemModelProvidable {
    var itemModel: AmountItemModel {
        guard showAutoclose else { return .empty }
        return .autoclose(
            ListItemModel(
                title: Localized.Perpetual.autoClose,
                subtitle: text.subtitle,
                subtitleExtra: text.subtitleExtra
            )
        )
    }
}
