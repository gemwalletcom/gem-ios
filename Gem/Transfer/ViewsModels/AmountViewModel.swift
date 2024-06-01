// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keystore
import Primitives
import BigInt
import Components
import Store
import SwiftUI
import Gemstone

enum AmountType: Equatable, Hashable {
    case transfer
    case stake(validators: [DelegationValidator])
    case unstake(delegation: Delegation)
    case redelegate(delegation: Delegation, validators: [DelegationValidator])
    case withdraw(delegation: Delegation)
}

class AmounViewModel: ObservableObject {
    let amountRecipientData: AmountRecipientData
    let wallet: Wallet
    let keystore: any Keystore
    let walletService: WalletService
    let stakeService: StakeService

    public init(
        amountRecipientData: AmountRecipientData,
        wallet: Wallet,
        keystore: any Keystore,
        walletService: WalletService,
        stakeService: StakeService,
        currentValidator: DelegationValidator? = .none
    ) {
        self.amountRecipientData = amountRecipientData
        self.wallet = wallet
        self.keystore = keystore
        self.walletService = walletService
        self.stakeService = stakeService
        
        if let validator = currentValidator {
            self.currentValidator = validators.contains(validator) ? validator : validators.first
        } else {
            self.currentValidator = validators.first
        }
    }
    
    private let formatter = ValueFormatter(style: .full)
    private let currencyFormatter = CurrencyFormatter.currency()

    @Published var currentValidator: DelegationValidator? = .none
    @Published var currentDelegation: Delegation? = .none

    var validators: [DelegationValidator] {
        switch amountRecipientData.type {
        case .transfer: []
        case .stake(let validators): validators
        case .unstake(let delegation): [delegation.validator]
        case .redelegate(_, let validators): validators
        case .withdraw(let delegation): [delegation.validator]
        }
    }
    
    var stakeValidatorsType: StakeValidatorsType {
        switch amountRecipientData.type {
        case .transfer, .stake, .redelegate: .stake
        case .unstake, .withdraw: .unstake
        }
    }
    
    var delegations: [Delegation] {
        switch amountRecipientData.type {
        case .transfer, .stake: []
        case .unstake(let delegation): [delegation]
        case .redelegate(let delegation, _): [delegation]
        case .withdraw(let delegation): [delegation]
        }
    }
    
    var title: String {
        return Localized.Transfer.Amount.title
    }
    
    var asset: Asset {
        amountRecipientData.data.asset
    }
    
    var assetSymbol: String {
        return amountRecipientData.data.asset.symbol
    }
    
    var assetImage: AssetImage {
        return AssetViewModel(asset: asset).assetImage
    }
    
    var assetName: String {
        return asset.name
    }
    
    var availableValue: BigInt {
        switch amountRecipientData.type {
        case .transfer, .stake:
            guard let balance = try? walletService.balanceService.getBalance(walletId: wallet.id, assetId: asset.id.identifier) else { return .zero }
            return balance.available
        case .unstake(let delegation):
            return delegation.base.balanceValue
        case .redelegate(let delegation, _):
            return delegation.base.balanceValue
        case .withdraw(let delegation):
            return delegation.base.balanceValue
        }
    }
    
    var maxBalance: String {
        formatter.string(availableValue, decimals: asset.decimals.asInt)
    }
    
    var balanceText: String {
        return ValueFormatter(style: .medium).string(
            availableValue,
            decimals: asset.decimals.asInt,
            currency: asset.symbol
        )
    }
    
    var isInputDisabled: Bool {
        !isAmountChangable
    }
    
    var isBalanceViewEnabled: Bool {
        !isInputDisabled
    }
    
    var isAmountChangable: Bool {
        switch amountRecipientData.type {
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
        switch amountRecipientData.type {
        case .transfer, .stake, .redelegate:
            return true
        case .unstake, .withdraw:
            return false
        }
    }
    
    var minimumValue: BigInt {
        let stakeChain = amountRecipientData.data.asset.chain.stakeChain
        switch amountRecipientData.type {
        case .stake:
            return BigInt(Config().getMinStakeAmount(chain: amountRecipientData.data.asset.chain.rawValue))
        case .redelegate:
            switch stakeChain {
            case .smartChain:
                return BigInt(Config().getMinStakeAmount(chain: amountRecipientData.data.asset.chain.rawValue))
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
    
    func isValidAmount(amount: String) throws -> BigInt {
        if amount.isEmpty {
            throw TransferError.invalidAmount
        }
        
        let value = try value(for: amount)
        
        if value.isZero {
            throw TransferError.invalidAmount
        }
        if minimumValue > value {
            throw TransferError.minimumAmount(string: minimumValueText)
        }
        
        return value
    }
    
    private func value(for amount: String) throws -> BigInt {
        return try formatter.inputNumber(from: amount, decimals: asset.decimals.asInt)
    }
    
    func getTransferData(value: BigInt) throws -> TransferData {
        let recipientAddress = stakeService.getRecipientAddress(chain: amountRecipientData.data.asset.chain.stakeChain, validatorId: currentValidator?.id)

        // make sure validator address is correct
        // FIXME. Refactor and add tests
        let stakeRecipientData = RecipientData(
            asset: amountRecipientData.data.asset,
            recipient: Recipient(
                name: currentValidator?.name,
                address: recipientAddress ?? "",
                memo: amountRecipientData.data.recipient.memo
            )
        )
        
        switch amountRecipientData.type {
        case .transfer:
            return TransferData(type: .transfer(asset), recipientData: amountRecipientData.data, value: value)
        case .stake:
            guard let validator = currentValidator else {
                throw TransferError.invalidAmount
            }
            return TransferData(type: .stake(asset, .stake(validator: validator)), recipientData: stakeRecipientData, value: value)
        case .unstake(let delegation):
            return TransferData(type: .stake(asset, .unstake(delegation: delegation)), recipientData: stakeRecipientData, value: value)
        case .redelegate(let delegation, _):
            guard let validator = currentValidator else {
                throw TransferError.invalidAmount
            }
            return TransferData(type: .stake(asset, .redelegate(delegation: delegation, toValidator: validator)), recipientData: stakeRecipientData, value: value)
        case .withdraw(let delegation):
            return TransferData(type: .stake(asset, .withdraw(delegation: delegation)), recipientData: stakeRecipientData, value: value)
        }
    }
    
    func fiatAmount(amount: String) -> String {
        guard
            let value = try? value(for: amount),
            let fiatValue = try? formatter.double(from: value, decimals: asset.decimals.asInt),
            let assetPrice = try? walletService.priceService.getPrice(for: asset.id) else {
            return .empty
        }
        return currencyFormatter.string(fiatValue * assetPrice.price)
    }
}
