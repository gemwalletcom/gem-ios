// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI
import Style
import Components
import Localization
import GemstonePrimitives
import StakeService

public struct StakeDetailViewModel {
    public let model: StakeDelegationViewModel
    public let onAmountInputAction: AmountInputAction

    private let wallet: Wallet
    private let service: StakeService

    public init(
        wallet: Wallet,
        model: StakeDelegationViewModel,
        service: StakeService,
        onAmountInputAction: AmountInputAction
    ) {
        self.wallet = wallet
        self.model = model
        self.service = service
        self.onAmountInputAction = onAmountInputAction
    }

    public var title: String {
        Localized.Transfer.Stake.title
    }
    
    public var stateText: String {
        model.state.title
    }
    
    public var stateTextStyle: TextStyle {
        TextStyle(font: .callout, color: model.stateTextColor)
    }
    
    public var aprTextStyle: TextStyle {
        if stakeApr > 0 {
            return TextStyle(font: .callout, color: Colors.green)
        }
        return .callout
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
        // TODO: - remove once, tron will be supportWidthdraw
        if chain == .tron {
            return model.state == .awaitingWithdrawal
        }
        return chain.supportWidthdraw && model.state == .awaitingWithdrawal
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
        return AmountInput(
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
    
    public func withdrawStakeRecipientData() throws -> AmountInput {
        AmountInput(
            type: .withdraw(delegation: model.delegation),
            asset: asset
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
