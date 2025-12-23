// Copyright (c). Gem Wallet. All rights reserved.

import Components
import Foundation
import Localization
import Primitives

struct AmountInfoViewModel {
    private let type: AmountType
    private let balanceViewModel: AmountBalanceViewModel
    private let amountTex: String

    init(
        type: AmountType,
        balanceViewModel: AmountBalanceViewModel,
        currentAmountText: String
    ) {
        self.type = type
        self.balanceViewModel = balanceViewModel
        self.amountTex = currentAmountText
    }

    var showInfo: Bool {
        switch type {
        case .transfer, .deposit, .withdraw, .stakeUnstake, .stakeRedelegate, .stakeWithdraw, .perpetual: false
        case .stake, .freeze: balanceViewModel.shouldReserveFee && amountTex == balanceViewModel.maxBalanceText
        }
    }
}

// MARK: - ItemModelProvidable

extension AmountInfoViewModel: ItemModelProvidable {
    var itemModel: AmountItemModel {
        switch showInfo {
        case true: .info(AmountInfoItemModel(text: Localized.Transfer.reservedFees(balanceViewModel.reservedFeesText)))
        case false: .empty
        }
    }
}
