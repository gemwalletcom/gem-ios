// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI
import Style
import Components

struct StakeDetailViewModel {
    
    let wallet: Wallet
    let model: StakeDelegationViewModel
    let service: StakeService

    var title: String {
        return Localized.Transfer.Stake.title
    }
    
    private var asset: Asset {
        model.delegation.base.assetId.chain.asset
    }
    
    private var stakeApr: Double {
        model.delegation.validator.apr
    }
    
    private var chain: StakeChain {
        StakeChain(rawValue: asset.chain.rawValue)!
    }
    
    var stateText: String {
        model.state.title
    }
    
    var stateTextStyle: TextStyle {
        TextStyle(font: .callout, color: model.stateTextColor)
    }
    
    var aprTextStyle: TextStyle {
        if stakeApr > 0 {
            return TextStyle(font: .callout, color: Colors.green)
        }
        return .callout
    }
    
    var validatorText: String {
        model.validatorText
    }
    
    var validatorAprText: String {
        CurrencyFormatter(type: .percentSignLess).string(model.delegation.validator.apr)
    }
    
    var showManage: Bool {
        [
            isStakeAvailable,
            isUnstakeAvailable,
            isRedelegateAvailable,
            isWithdrawStakeAvailable,
        ].contains(true)
    }
    
    var isStakeAvailable: Bool {
        chain.supportRedelegate && model.state == .active
    }
    
    var isUnstakeAvailable: Bool {
        (model.state == .active || model.state == .inactive) && model.state != .awaitingWithdrawal
    }
    
    var isRedelegateAvailable: Bool {
        (model.state == .active || model.state == .inactive) && chain.supportRedelegate
    }
    
    var isWithdrawStakeAvailable: Bool {
        model.state == .awaitingWithdrawal
    }
    
    var completionDateTitle: String? {
        switch model.state {
        case .pending, .deactivating:
            Localized.Stake.availableIn
        case .activating:
            Localized.Stake.activeIn
        default: .none
        }
    }
    
    var completionDateText: String? {
        model.completionDateText
    }
    
    private var recommendedCurrentValidator: DelegationValidator? {
        guard let validatorId = StakeRecommendedValidators().randomValidatorId(chain: model.delegation.base.assetId.chain) else {
            return .none
        }
        return try? service.store.getValidator(assetId: asset.id, validatorId: validatorId)
    }
    
    func stakeRecipientData() throws -> AmountInput {
        AmountInput(
            type: .stake(
                validators: try service.getActiveValidators(assetId: asset.id),
                recommendedValidator: model.delegation.validator
            ),
            asset: asset
        )
    }
    
    func unstakeRecipientData() throws -> AmountInput {
        AmountInput(
            type: .unstake(delegation: model.delegation),
            asset: asset
        )
    }
    
    func redelegateRecipientData() throws -> AmountInput {
        AmountInput(
            type: .redelegate(
                delegation: model.delegation,
                validators: try service.store.getValidators(assetId: asset.id),
                recommendedValidator: recommendedCurrentValidator
            ),
            asset: asset
        )
    }
    
    func withdrawStakeRecipientData() throws -> AmountInput {
        AmountInput(
            type: .withdraw(delegation: model.delegation),
            asset: asset
        )
    }
}
