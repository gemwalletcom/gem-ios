// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt
import Components
import Store
import SwiftUI
import Gemstone
import GemstonePrimitives
import Localization
import Transfer
import enum Staking.StakeValidatorsType
import StakeService
import PrimitivesComponents
import WalletsService

@MainActor
@Observable
final class AmounViewModel {
    let input: AmountInput
    let wallet: Wallet
    let walletsService: WalletsService
    let stakeService: StakeService
    let onTransferAction: TransferDataAction
    
    var amountText: String = ""
    var delegation: DelegationValidator?
    var currentValidator: DelegationValidator? = .none
    var currentDelegation: Delegation? = .none
    var amountInputType: AmountInputType = .asset

    public init(
        input: AmountInput,
        wallet: Wallet,
        walletsService: WalletsService,
        stakeService: StakeService,
        onTransferAction: TransferDataAction
    ) {
        self.input = input
        self.wallet = wallet
        self.walletsService = walletsService
        self.stakeService = stakeService
        self.onTransferAction = onTransferAction

        self.currentValidator = defaultValidator
    }
    
    private let formatter = ValueFormatter(style: .full)
    private let currencyFormatter = CurrencyFormatter.currency()
    
    var type: AmountType { input.type }
    var asset: Asset { input.asset }
    var assetImage: AssetImage { AssetViewModel(asset: asset).assetImage }
    var assetName: String { asset.name }
    var isInputDisabled: Bool { !isAmountChangable }
    var isBalanceViewEnabled: Bool { !isInputDisabled }
    
    var amountTransferValue: String {
        switch amountInputType {
        case .asset: amountText
        case .fiat: amountValue().valueOrEmpty
        }
    }

    var inputConfig: any CurrencyInputConfigurable {
        AmountInputConfig(
            type: amountInputType,
            asset: asset,
            currencyFormatter: currencyFormatter,
            secondaryText: secondaryText,
            onTapActionButton: handleInputAction
        )
    }
    
    var secondaryText: String {
        switch amountInputType {
        case .asset: fiatValueText()
        case .fiat: amountValueText()
        }
    }

    var defaultValidator: DelegationValidator? {
        let recommended: DelegationValidator? = switch type {
        case .stake(_, let recommendedValidator): recommendedValidator
        case .redelegate(_, _, let recommendedValidator): recommendedValidator
        case .transfer, .unstake, .withdraw: .none
        }
        return recommended ?? validators.first
    }

    var validators: [DelegationValidator] {
        switch type {
        case .transfer: []
        case .stake(let validators, _): validators
        case .unstake(let delegation): [delegation.validator]
        case .redelegate(_, let validators, _): validators
        case .withdraw(let delegation): [delegation.validator]
        }
    }
    
    var stakeValidatorsType: StakeValidatorsType {
        switch type {
        case .transfer, .stake, .redelegate: .stake
        case .unstake, .withdraw: .unstake
        }
    }
    
    var delegations: [Delegation] {
        switch type {
        case .transfer, .stake: []
        case .unstake(let delegation): [delegation]
        case .redelegate(let delegation, _, _): [delegation]
        case .withdraw(let delegation): [delegation]
        }
    }
    
    var title: String {
        switch type {
        case .transfer: Localized.Transfer.Send.title
        case .stake: Localized.Transfer.Stake.title
        case .unstake: Localized.Transfer.Unstake.title
        case .redelegate: Localized.Transfer.Redelegate.title
        case .withdraw: Localized.Transfer.Withdraw.title
        }
    }
    
    var availableValue: BigInt {
        switch input.type {
        case .transfer, .stake:
            guard let balance = try? walletsService.balanceService.getBalance(walletId: wallet.id, assetId: asset.id.identifier) else { return .zero }
            return balance.available
        case .unstake(let delegation):
            return delegation.base.balanceValue
        case .redelegate(let delegation, _, _):
            return delegation.base.balanceValue
        case .withdraw(let delegation):
            return delegation.base.balanceValue
        }
    }
    
    var maxBalance: String {
        formatter.string(availableValue, decimals: asset.decimals.asInt)
    }
    
    var balanceText: String {
        ValueFormatter(style: .medium).string(
            availableValue,
            decimals: asset.decimals.asInt,
            currency: asset.symbol
        )
    }
    
    var isAmountChangable: Bool {
        switch type {
        case .transfer,
            .stake,
            .redelegate:
            return true
        case .unstake:
            if let chain = StakeChain(rawValue: asset.chain.rawValue) {
                return chain.canChangeAmountOnUnstake
            }
            return true
        case .withdraw:
            return false
        }
    }
    
    var isSelectValidatorEnabled: Bool {
        switch type {
        case .transfer, .stake, .redelegate:
            return true
        case .unstake, .withdraw:
            return false
        }
    }
    
    var minimumValue: BigInt {
        let stakeChain = asset.chain.stakeChain
        switch type {
        case .stake:
            return BigInt(StakeConfig.config(chain: stakeChain!).minAmount)
        case .redelegate:
            switch stakeChain {
            case .smartChain:
                return BigInt(StakeConfig.config(chain: stakeChain!).minAmount)
            default:
                break
            }
        case .unstake, .withdraw, .transfer:
            break
        }
        return BigInt(0)
    }
    
    var minimumValueText: String {
        ValueFormatter(style: .short).string(
            minimumValue,
            decimals: asset.decimals.asInt,
            currency: asset.symbol
        )
    }

    var recipientData: RecipientData {
        switch type {
        case .transfer(recipient: let recipient):
            return recipient
        case .stake,
            .unstake,
            .redelegate,
            .withdraw:
            
            let recipientAddress = self.stakeService.getRecipientAddress(
                chain: asset.chain.stakeChain,
                type: type,
                validatorId: currentValidator?.id
            )
            
            return RecipientData(
                recipient: Recipient(
                    name: currentValidator?.name,
                    address: recipientAddress ?? "",
                    memo: Localized.Stake.viagem
                ),
                amount: .none
            )
        }
    }
    
    // MARK: - Private methods
    
    private func isValidAmount() throws -> BigInt {
        if amountTransferValue.isEmpty {
            throw TransferError.invalidAmount
        }
        
        let value = try value(for: amountTransferValue)
        
        if value.isZero {
            throw TransferError.invalidAmount
        }
        if minimumValue > value {
            throw TransferError.minimumAmount(string: minimumValueText)
        }
        
        return value
    }
    
    private func getTransferData(value: BigInt, canChangeValue: Bool) throws -> TransferData {
        switch type {
        case .transfer:
            return TransferData(
                type: .transfer(asset),
                recipientData: recipientData,
                value: value,
                canChangeValue: canChangeValue
            )
        case .stake:
            guard let validator = currentValidator else {
                throw TransferError.invalidAmount
            }
            return TransferData(
                type: .stake(asset, .stake(validator: validator)),
                recipientData: recipientData,
                value: value,
                canChangeValue: canChangeValue
            )
        case .unstake(let delegation):
            return TransferData(
                type: .stake(asset, .unstake(delegation: delegation)),
                recipientData: recipientData,
                value: value,
                canChangeValue: canChangeValue
            )
        case .redelegate(let delegation, _, _):
            guard let validator = currentValidator else {
                throw TransferError.invalidAmount
            }
            return TransferData(
                type: .stake(asset, .redelegate(delegation: delegation, toValidator: validator)),
                recipientData: recipientData,
                value: value,
                canChangeValue: canChangeValue
            )
        case .withdraw(let delegation):
            return TransferData(
                type: .stake(asset, .withdraw(delegation: delegation)),
                recipientData: recipientData,
                value: value,
                canChangeValue: canChangeValue
            )
        }
    }
    
    private func value(for amount: String) throws -> BigInt {
        try formatter.inputNumber(from: amount, decimals: asset.decimals.asInt)
    }
    
    private func fiatValueText() -> String {
        guard let fiatValue = fiatValue() else {
            return .empty
        }
        return currencyFormatter.string(fiatValue.doubleValue)
    }
    
    private func amountValueText() -> String {
        guard let amount = amountValue(),
              amount.isNotEmpty
        else {
            return .empty
        }
        return [amount, asset.symbol].joined(separator: " ")
    }
    
    private func amountValue() -> String? {
        guard let amountValue = try? walletsService.priceService.convertToAmount(fiatValue: amountText, asset: asset) else {
            return nil
        }
        return amountValue
    }
    
    private func fiatValue() -> Decimal? {
        guard amountText.isNotEmpty,
              let fiatValue = try? walletsService.priceService.convertToFiat(amount: amountText, asset: asset),
              !fiatValue.isZero
        else {
            return nil
        }
        return fiatValue
    }
    
    private func handleInputAction() {
        toggleAmountInputType()
        replaceAmountText()
    }
    
    private func toggleAmountInputType() {
        switch amountInputType {
        case .asset: amountInputType = .fiat
        case .fiat: amountInputType = .asset
        }
    }
    
    private func replaceAmountText() {
        switch amountInputType {
        case .asset:
            amountText = amountValue() ?? .empty
        case .fiat:
            if let fiatValue = fiatValue() {
                amountText = currencyFormatter.string(decimal: fiatValue)
            }
        }
    }
}

// MARK: - Logic

extension AmounViewModel {
    func setRecipientAmount() {
        if let recipientAmount = recipientData.amount {
            amountText = recipientAmount
        }
    }
    
    func setMax() {
        amountInputType = .asset
        amountText = maxBalance
    }

    func resetAmount() {
        amountText = .empty
    }
    
    func setCurrentValidator() {
        delegation = currentValidator
    }
    
    func setSelectedValidator(_ validator: DelegationValidator) {
        currentValidator = validator
    }
    
    func onNext() throws {
        let transfer = try getTransferData(value: try isValidAmount(), canChangeValue: true)
        onTransferAction?(transfer)
    }
}
