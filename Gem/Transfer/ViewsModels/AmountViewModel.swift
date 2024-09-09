// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keystore
import Primitives
import BigInt
import Components
import Store
import SwiftUI
import Gemstone
import GemstonePrimitives

class AmounViewModel: ObservableObject {
    let input: AmountInput
    let wallet: Wallet
    let keystore: any Keystore
    let walletsService: WalletsService
    let stakeService: StakeService

    public init(
        input: AmountInput,
        wallet: Wallet,
        keystore: any Keystore,
        walletsService: WalletsService,
        stakeService: StakeService
    ) {
        self.input = input
        self.wallet = wallet
        self.keystore = keystore
        self.walletsService = walletsService
        self.stakeService = stakeService

        self.currentValidator = defaultValidator
    }
    
    private let formatter = ValueFormatter(style: .full)
    private let currencyFormatter = CurrencyFormatter.currency()

    @Published var currentValidator: DelegationValidator? = .none
    @Published var currentDelegation: Delegation? = .none

    var recipientField: String { Localized.Transfer.Recipient.addressField }
    var memoField: String { Localized.Transfer.memo }

    var defaultValidator: DelegationValidator? {
        let recommended: DelegationValidator? = switch type {
        case .stake(_, let recommendedValidator): recommendedValidator
        case .redelegate(_, _, let recommendedValidator): recommendedValidator
        case .transfer, .unstake, .withdraw: .none
        }
        return recommended ?? validators.first
    }

    var showMemo: Bool {
        AssetViewModel(asset: input.asset).supportMemo
    }

    var type: AmountType {
        input.type
    }

    var asset: Asset {
        input.asset
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
        return Localized.Transfer.Amount.title
    }

    var assetSymbol: String {
        return asset.symbol
    }
    
    var assetImage: AssetImage {
        return AssetViewModel(asset: asset).assetImage
    }
    
    var assetName: String {
        return asset.name
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

    private func isValidAddress(address: String) -> Bool {
        return asset.chain.isValidAddress(address)
    }

    func getRecipientData(name: NameRecord?, address: String, memo: String?) throws -> RecipientData {
        let recipient: Recipient = {
            if let result = name {
                return Recipient(name: result.name, address: result.address, memo: memo)
            }
            return Recipient(name: .none, address: address, memo: memo)
        }()

        guard isValidAddress(address: recipient.address) else {
            throw TransferError.invalidAddress(asset: asset)
        }

        switch type {
        case .transfer: 
            return RecipientData(
                asset: input.asset,
                recipient: recipient
            )
        case .stake, .unstake, .redelegate, .withdraw:
            let recipientAddress = self.stakeService.getRecipientAddress(
                chain: asset.chain.stakeChain,
                type: type,
                validatorId: currentValidator?.id
            )
            return RecipientData(
                asset: asset,
                recipient: Recipient(
                    name: currentValidator?.name,
                    address: recipientAddress ?? "",
                    memo: Localized.Stake.viagem
                )
            )
        }
    }

    func getTransferData(recipientData: RecipientData, value: BigInt, canChangeValue: Bool) throws -> TransferData {
        switch type {
        case .transfer:
            return TransferData(type: .transfer(asset), recipientData: recipientData, value: value, canChangeValue: canChangeValue)
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

    func fiatAmount(amount: String) -> String {
        guard
            let value = try? value(for: amount),
            let fiatValue = try? formatter.double(from: value, decimals: asset.decimals.asInt),
            let assetPrice = try? walletsService.priceService.getPrice(for: asset.id) else {
            return .empty
        }
        return currencyFormatter.string(fiatValue * assetPrice.price)
    }

    //TODO: Add unit tests
    func getTransferDataFromScan(string: String) throws -> ScanRecipientResult {
        let payment = try PaymentURLDecoder.decode(string)

        return ScanRecipientResult(
            address: payment.address,
            amount: payment.amount,
            memo: payment.memo
        )
    }
}
