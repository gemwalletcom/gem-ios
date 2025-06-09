// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt
import Components
import GemstonePrimitives
import Localization
import StakeService
import PrimitivesComponents
import WalletsService
import Staking
import Style
import Preferences

@MainActor
@Observable
public final class AmountSceneViewModel {
    let input: AmountInput
    let wallet: Wallet
    let walletsService: WalletsService
    let stakeService: StakeService
    let onTransferAction: TransferDataAction

    var delegation: DelegationValidator?
    var focusField: Bool = false

    var amountInputModel: InputValidationViewModel = InputValidationViewModel()

    private let formatter = ValueFormatter(style: .full)
    private let currencyFormatter = CurrencyFormatter(type: .currency, currencyCode: Preferences.standard.currency)
    private let numberSanitizer = NumberSanitizer()
    private let valueConverter = ValueConverter()

    private var currentValidator: DelegationValidator?
    private var currentDelegation: Delegation?
    private var amountInputType: AmountInputType = .asset

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

        self.amountInputModel = InputValidationViewModel(mode: .onDemand, validators: inputValidators)

        // set amount if avaialbe in recipientData
        if let recipientAmount = recipientData.amount {
            amountInputModel.update(text: recipientAmount)
        }
    }
    
    var type: AmountType { input.type }
    var asset: Asset { input.asset }
    var assetImage: AssetImage { AssetViewModel(asset: asset).assetImage }
    var assetName: String { asset.name }

    var isInputDisabled: Bool { !isAmountChangable }
    var isBalanceViewEnabled: Bool { !isInputDisabled }
    var isNextEnabled: Bool { actionButtonState == .normal }

    var actionButtonState: StateButtonStyle.State {
        amountInputModel.text.isNotEmpty && amountInputModel.isValid ? .normal : .disabled
    }

    var validatorTitle: String { Localized.Stake.validator }
    var maxTitle: String { Localized.Transfer.max }
    var nextTitle: String { Localized.Common.next }
    var continueTitle: String { Localized.Common.continue }

    var inputConfig: any CurrencyInputConfigurable {
        AmountInputConfig(
            sceneType: type,
            inputType: amountInputType,
            asset: asset,
            currencyFormatter: currencyFormatter,
            numberSanitizer: numberSanitizer,
            secondaryText: secondaryText,
            onTapActionButton: onSelectInputButton
        )
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

    var secondaryText: String {
        switch amountInputType {
        case .asset: fiatValueText
        case .fiat: amountValueText
        }
    }

    var balanceText: String {
        ValueFormatter(style: .medium).string(
            availableValue,
            decimals: asset.decimals.asInt,
            currency: asset.symbol
        )
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
    
    var stakeValidatorViewModel: StakeValidatorViewModel? {
        guard let currentValidator else { return nil }
        return StakeValidatorViewModel(validator: currentValidator)
    }
    
    var delegations: [Delegation] {
        switch type {
        case .transfer, .stake: []
        case .unstake(let delegation): [delegation]
        case .redelegate(let delegation, _, _): [delegation]
        case .withdraw(let delegation): [delegation]
        }
    }
    
    var isSelectValidatorEnabled: Bool {
        switch type {
        case .transfer, .stake, .redelegate: true
        case .unstake, .withdraw: false
        }
    }
}

// MARK: - Business Logic

extension AmountSceneViewModel {
    func onAppear() {
        if isAmountChangable {
            focusField = true
        } else {
            setMax()
        }
    }

    func onSelectNextButton() {
        do {
            try onNext()
        } catch {
            amountInputModel.update(error: error)
        }
    }

    func onSelectMaxButton() {
        setMax()
        focusField = false
    }

    func onSelectCurrentValidator() {
        delegation = currentValidator
    }

    func onSelectValidator(_ validator: DelegationValidator) {
        cleanInput()
        setSelectedValidator(validator)
    }
}

// MARK: - Private

extension AmountSceneViewModel {
    private func onSelectInputButton() {
        switch amountInputType {
        case .asset: amountInputType = .fiat
        case .fiat: amountInputType = .asset
        }
        cleanInput()
    }

    private func setMax() {
        amountInputType = .asset
        amountInputModel.update(text: maxBalance)
    }

    private func cleanInput() {
        amountInputModel.text = .empty
        amountInputModel.update(validators: inputValidators)
    }

    private func setSelectedValidator(_ validator: DelegationValidator) {
        currentValidator = validator
    }

    private func onNext() throws {
        let value = try value(for: amountTransferValue)
        let transfer = try getTransferData(value: value, canChangeValue: true)
        onTransferAction?(transfer)
    }

    private var recipientData: RecipientData {
        switch type {
        case .transfer(recipient: let recipient):
            return recipient
        case .stake,
            .unstake,
            .redelegate,
            .withdraw:

            let recipientAddress = stakeService.getRecipientAddress(
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

    private var inputValidators: [any TextValidator] {
        let source: AmountValidator.Source = switch amountInputType {
        case .asset: .asset
        case .fiat: .fiat(price: getAssetPrice(), converter: valueConverter)
        }

        return [
            .amount(
                source: source,
                decimals: asset.decimals.asInt,
                validators: [
                    PositiveValueValidator<BigInt>().silent,
                    MinimumValueValidator<BigInt>(minimumValue: minimumValue, minimumValueText: minimumValueText),
                    MinimumAccountReserveValidator<BigInt>(available: availableValue, reserve: minimumAccountReserve, asset: asset),
                    BalanceValueValidator<BigInt>(available: availableValue, asset: asset)
                ]
            )
        ]
    }

    private var fiatValueText: String {
        currencyFormatter.string(fiatValue.doubleValue)
    }

    private var amountValueText: String {
        [amountValue, asset.symbol].joined(separator: " ")
    }

    private var amountValue: String {
        guard let price = getAssetPrice() else { return .zero }
        return (try? valueConverter.convertToAmount(
            fiatValue: amountInputModel.text,
            price: price,
            decimals: asset.decimals.asInt
        )).or(.zero)
    }

    private var fiatValue: Decimal {
        guard let price = getAssetPrice() else { return .zero }
        return (try? valueConverter.convertToFiat(
            amount: amountInputModel.text,
            price: price
        )).or(.zero)
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

    private func getAssetPrice() -> AssetPrice? {
        try? walletsService.priceService.getPrice(for: asset.id)
    }

    private var minimumValue: BigInt {
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

    private var defaultValidator: DelegationValidator? {
        let recommended: DelegationValidator? = switch type {
        case .stake(_, let recommendedValidator): recommendedValidator
        case .redelegate(_, _, let recommendedValidator): recommendedValidator
        case .transfer, .unstake, .withdraw: .none
        }
        return recommended ?? validators.first
    }

    private var availableValue: BigInt {
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

    private var maxBalance: String {
        formatter.string(availableValue, decimals: asset.decimals.asInt)
    }

    private var minimumValueText: String {
        ValueFormatter(style: .short).string(
            minimumValue,
            decimals: asset.decimals.asInt,
            currency: asset.symbol
        )
    }

    private var isAmountChangable: Bool {
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

    private var amountTransferValue: String {
        switch amountInputType {
        case .asset: amountInputModel.text
        case .fiat: amountValue
        }
    }

    private var minimumAccountReserve: BigInt {
        asset.type == .native ? asset.chain.minimumAccountBalance : .zero
    }
}
