// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI
import Style
import Components
import Localization
import StakeService
import Formatters

public struct StakeDetailViewModel {
    public let model: StakeDelegationViewModel
    public let onAmountInputAction: AmountInputAction
    public let onTransferAction: TransferDataAction

    private let wallet: Wallet
    private let service: StakeService

    public init(
        wallet: Wallet,
        model: StakeDelegationViewModel,
        service: StakeService,
        onAmountInputAction: AmountInputAction,
        onTransferAction: TransferDataAction
    ) {
        self.wallet = wallet
        self.model = model
        self.service = service
        self.onAmountInputAction = onAmountInputAction
        self.onTransferAction = onTransferAction
    }

    public var title: String { Localized.Transfer.Stake.title }
    public var validatorTitle: String { Localized.Stake.validator }
    public var aprTitle: String { Localized.Stake.apr("") }
    public var stateTitle: String { Localized.Transaction.status }
    public var balancesTitle: String { Localized.Asset.balances }
    public var manageTitle: String { Localized.Common.manage }
    public var rewardsTitle: String { Localized.Stake.rewards }
    public var unstakeTitle: String { Localized.Transfer.Unstake.title }
    public var redelegateTitle: String { Localized.Transfer.Redelegate.title }
    public var withdrawTitle: String { Localized.Transfer.Withdraw.title }

    public var stateText: String {
        model.state.title
    }
    
    public var stateTextStyle: TextStyle {
        TextStyle(font: .callout, color: model.stateTextColor)
    }
    
    public var validatorText: String {
        model.validatorText
    }
    
    public var validatorAprText: String {
        CurrencyFormatter(type: .percentSignLess).string(model.delegation.validator.apr)
    }
    
    public var showManage: Bool {
        [
            isStakeAvailable,
            isUnstakeAvailable,
            isRedelegateAvailable,
            isWithdrawStakeAvailable,
        ].contains(true)
    }
    
    public var isStakeAvailable: Bool {
        chain.supportRedelegate && model.state == .active
    }
    
    public var isUnstakeAvailable: Bool {
        [.active, .inactive].contains(model.state) && model.state != .awaitingWithdrawal
    }
    
    public var isRedelegateAvailable: Bool {
        chain.supportRedelegate && [.active, .inactive].contains(model.state)
    }
    
    public var isWithdrawStakeAvailable: Bool {
        chain.supportWidthdraw && model.state == .awaitingWithdrawal
    }

    public var showValidatorApr: Bool {
        !model.delegation.validator.apr.isZero
    }

    public var completionDateTitle: String? {
        switch model.state {
        case .pending, .deactivating:
            Localized.Stake.availableIn
        case .activating:
            Localized.Stake.activeIn
        default: .none
        }
    }
    
    public var completionDateText: String? {
        model.completionDateText
    }
    
    public var validatorUrl: URL? {
        model.validatorUrl
    }
    
    public func stakeRecipientData() throws -> AmountInput {
        AmountInput(
            type: .stake(
                validators: try service.getActiveValidators(assetId: asset.id),
                recommendedValidator: model.delegation.validator
            ),
            asset: asset
        )
    }
    
    public func unstakeRecipientData() throws -> AmountInput {
        AmountInput(
            type: .unstake(delegation: model.delegation),
            asset: asset
        )
    }
    
    public func redelegateRecipientData() throws -> AmountInput {
        return AmountInput(
            type: .redelegate(
                delegation: model.delegation,
                validators: try service.getActiveValidators(assetId: asset.id),
                recommendedValidator: recommendedCurrentValidator
            ),
            asset: asset
        )
    }
    
    public func withdrawStakeTransferData() throws -> TransferData {
        TransferData(
            type: .stake(asset, .withdraw(delegation: model.delegation)),
            recipientData: RecipientData(
                recipient: Recipient(name: validatorText, address: model.delegation.validator.id, memo: ""),
                amount: .none
            ),
            value: model.delegation.base.balanceValue,
            canChangeValue: false,
            ignoreValueCheck: true
        )
    }
}

// MARK: - Private

extension StakeDetailViewModel {
    private var asset: Asset {
        model.delegation.base.assetId.chain.asset
    }

    private var stakeApr: Double {
        model.delegation.validator.apr
    }

    private var chain: StakeChain {
        StakeChain(rawValue: asset.chain.rawValue)!
    }

    private var recommendedCurrentValidator: DelegationValidator? {
        guard let validatorId = StakeRecommendedValidators().randomValidatorId(chain: model.delegation.base.assetId.chain) else {
            return .none
        }
        return try? service.getValidator(assetId: asset.id, validatorId: validatorId)
    }
}
