// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI
import Style
import Components
import Localization
import Formatters
import PrimitivesComponents

public struct EarnDetailSceneViewModel {
    public let model: DelegationViewModel
    public let onAmountInputAction: AmountInputAction
    public let onTransferAction: TransferDataAction

    private let wallet: Wallet
    private let asset: Asset

    public init(
        wallet: Wallet,
        model: DelegationViewModel,
        asset: Asset,
        onAmountInputAction: AmountInputAction,
        onTransferAction: TransferDataAction
    ) {
        self.wallet = wallet
        self.model = model
        self.asset = asset
        self.onAmountInputAction = onAmountInputAction
        self.onTransferAction = onTransferAction
    }

    public var title: String { Localized.Common.earn }
    public var aprTitle: String { Localized.Stake.apr("") }
    public var stateTitle: String { Localized.Transaction.status }
    public var manageTitle: String { Localized.Common.manage }
    public var rewardsTitle: String { Localized.Stake.rewards }
    public var depositTitle: String { Localized.Wallet.deposit }
    public var withdrawTitle: String { Localized.Transfer.Withdraw.title }

    public var headerViewModel: HeaderViewModel {
        DelegationViewModel(delegation: model.delegation, asset: asset, formatter: .auto, currencyCode: model.currencyCode)
    }

    public var providerTitle: String { Localized.Common.provider }
    public var providerText: String { model.validatorText }
    public var showApr: Bool { !model.delegation.validator.apr.isZero }
    public var aprText: String { CurrencyFormatter.percentSignLess.string(model.delegation.validator.apr) }
    public var delegationModel: DelegationViewModel { model }

    public var stateText: String {
        DelegationStateViewModel(state: model.state).title
    }

    public var stateTextStyle: TextStyle {
        TextStyle(font: .callout, color: model.stateTextColor)
    }

    public var showManage: Bool {
        guard wallet.canSign else { return false }
        return isDepositAvailable || isWithdrawAvailable
    }

    public var isDepositAvailable: Bool {
        model.state == .active
    }

    public var isWithdrawAvailable: Bool {
        [.active, .inactive].contains(model.state)
    }

    public var assetImageStyle: ListItemImageStyle? {
        .asset(assetImage: AssetViewModel(asset: asset).assetImage)
    }
}

// MARK: - Actions

extension EarnDetailSceneViewModel {
    public func onDepositAction() {
        let data = AmountInput(
            type: .earn(.deposit(model.delegation.validator)),
            asset: asset
        )
        onAmountInputAction?(data)
    }

    public func onWithdrawAction() {
        let data = AmountInput(
            type: .earn(.withdraw(model.delegation)),
            asset: asset
        )
        onAmountInputAction?(data)
    }
}
