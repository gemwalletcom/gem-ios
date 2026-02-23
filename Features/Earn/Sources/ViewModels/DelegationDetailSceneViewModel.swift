// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI
import Style
import Components
import Localization
import Formatters
import PrimitivesComponents
import GemstonePrimitives

public struct DelegationDetailSceneViewModel {
    public let model: DelegationViewModel
    public let validators: [DelegationValidator]
    public let onAmountInputAction: AmountInputAction
    public let onTransferAction: TransferDataAction

    private let wallet: Wallet
    private let asset: Asset

    public init(
        wallet: Wallet,
        model: DelegationViewModel,
        asset: Asset,
        validators: [DelegationValidator],
        onAmountInputAction: AmountInputAction,
        onTransferAction: TransferDataAction
    ) {
        self.wallet = wallet
        self.model = model
        self.asset = asset
        self.validators = validators
        self.onAmountInputAction = onAmountInputAction
        self.onTransferAction = onTransferAction
    }

    public var title: String {
        switch providerType {
        case .stake: Localized.Transfer.Stake.title
        case .earn: Localized.Common.earn
        }
    }

    public var providerTitle: String {
        switch providerType {
        case .stake: Localized.Stake.validator
        case .earn: Localized.Common.provider
        }
    }

    public var providerText: String { model.validatorText }
    public var aprTitle: String { Localized.Stake.apr("") }
    public var stateTitle: String { Localized.Transaction.status }
    public var manageTitle: String { Localized.Common.manage }
    public var rewardsTitle: String { Localized.Stake.rewards }

    public var headerViewModel: HeaderViewModel {
        DelegationViewModel(delegation: model.delegation, asset: asset, formatter: .auto, currencyCode: model.currencyCode)
    }

    public var stateText: String {
        DelegationStateViewModel(state: model.state).title
    }

    public var stateTextStyle: TextStyle {
        DelegationStateViewModel(state: model.state).textStyle
    }

    public var showApr: Bool {
        !model.delegation.validator.apr.isZero
    }

    public var aprText: String {
        CurrencyFormatter.percentSignLess.string(model.delegation.validator.apr)
    }

    public var providerUrl: URL? {
        switch providerType {
        case .stake: model.validatorUrl
        case .earn: nil
        }
    }

    public var completionDateTitle: String? {
        switch providerType {
        case .stake:
            switch model.state {
            case .pending, .deactivating: Localized.Stake.availableIn
            case .activating: Localized.Stake.activeIn
            default: .none
            }
        case .earn: .none
        }
    }

    public var completionDateText: String? {
        switch providerType {
        case .stake: model.completionDateText
        case .earn: .none
        }
    }

    public var assetImageStyle: ListItemImageStyle? {
        .asset(assetImage: AssetViewModel(asset: asset).assetImage)
    }

    public var availableActions: [DelegationDetailActionType] {
        guard wallet.canSign else { return [] }
        return switch providerType {
        case .stake:
            switch model.state {
            case .active: chain.supportRedelegate ? [.stake, .unstake, .redelegate] : [.unstake]
            case .inactive: chain.supportRedelegate ? [.unstake, .redelegate] : [.unstake]
            case .awaitingWithdrawal: chain.supportWidthdraw ? [.withdraw] : []
            case .pending, .activating, .deactivating: []
            }
        case .earn:
            switch model.state {
            case .active: [.deposit, .withdraw]
            case .inactive: [.withdraw]
            case .pending, .activating, .deactivating, .awaitingWithdrawal: []
            }
        }
    }

    public var showManage: Bool {
        !availableActions.isEmpty
    }

    public func actionTitle(_ action: DelegationDetailActionType) -> String {
        switch action {
        case .stake: Localized.Transfer.Stake.title
        case .unstake: Localized.Transfer.Unstake.title
        case .redelegate: Localized.Transfer.Redelegate.title
        case .deposit: Localized.Wallet.deposit
        case .withdraw: Localized.Transfer.Withdraw.title
        }
    }
}

// MARK: - Actions

extension DelegationDetailSceneViewModel {
    public func onSelectAction(_ action: DelegationDetailActionType) {
        switch action {
        case .stake:
            onAmountInputAction?(amountInput(.stake(.stake(validators: validators, recommended: model.delegation.validator))))
        case .unstake:
            if chain.canChangeAmountOnUnstake {
                onAmountInputAction?(amountInput(.stake(.unstake(model.delegation))))
            } else {
                onTransferAction?(stakeTransferData(.unstake(model.delegation)))
            }
        case .redelegate:
            onAmountInputAction?(amountInput(.stake(.redelegate(model.delegation, validators: validators, recommended: recommendedCurrentValidator))))
        case .deposit:
            onAmountInputAction?(amountInput(.earn(.deposit(model.delegation.validator))))
        case .withdraw:
            switch providerType {
            case .stake: onTransferAction?(stakeTransferData(.withdraw(model.delegation)))
            case .earn: onAmountInputAction?(amountInput(.earn(.withdraw(model.delegation))))
            }
        }
    }
}

// MARK: - Private

extension DelegationDetailSceneViewModel {
    private func amountInput(_ type: AmountType) -> AmountInput {
        AmountInput(type: type, asset: asset)
    }

    private func stakeTransferData(_ stakeType: StakeType) -> TransferData {
        TransferData(
            type: .stake(asset, stakeType),
            recipientData: RecipientData(
                recipient: Recipient(name: providerText, address: model.delegation.validator.id, memo: ""),
                amount: .none
            ),
            value: model.delegation.base.balanceValue
        )
    }

    private var providerType: EarnProviderType {
        model.delegation.validator.providerType
    }

    private var chain: StakeChain {
        StakeChain(rawValue: asset.chain.rawValue)!
    }

    private var recommendedCurrentValidator: DelegationValidator? {
        guard let validatorId = StakeRecommendedValidators().randomValidatorId(chain: model.delegation.base.assetId.chain) else {
            return .none
        }
        return validators.first(where: { $0.id == validatorId })
    }
}
