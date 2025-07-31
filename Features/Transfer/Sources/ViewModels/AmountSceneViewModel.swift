// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Components
import Formatters
import Foundation
import GemstonePrimitives
import InfoSheet
import Localization
import Preferences
import Primitives
import PrimitivesComponents
import StakeService
import Staking
import Style
import Validators
import WalletsService

@MainActor
@Observable
public final class AmountSceneViewModel {
    private let input: AmountInput
    private let wallet: Wallet

    private let amountService: AmountService
    private let onTransferAction: TransferDataAction

    private let formatter = ValueFormatter(style: .full)
    private let currencyFormatter = CurrencyFormatter(type: .currency, currencyCode: Preferences.standard.currency)
    private let numberSanitizer = NumberSanitizer()
    private let valueConverter = ValueConverter()

    private var currentValidator: DelegationValidator?
    private var currentDelegation: Delegation?
    private var amountInputType: AmountInputType = .asset {
        didSet { amountInputModel.update(validators: inputValidators) }
    }

    var amountInputModel: InputValidationViewModel = InputValidationViewModel()
    var delegation: DelegationValidator?
    var isPresentingSheet: AmountSheetType?
    var focusField: Bool = false

    public init(
        input: AmountInput,
        wallet: Wallet,
        amountService: AmountService,
        onTransferAction: TransferDataAction
    ) {
        self.input = input
        self.wallet = wallet
        self.amountService = amountService
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

    var isInputDisabled: Bool { !canChangeValue }
    var isBalanceViewEnabled: Bool { !isInputDisabled }
    var isNextEnabled: Bool { actionButtonState == .normal }

    var actionButtonState: ButtonState {
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
        case .deposit: "Deposit"
        case .perpetual(_, let data):
            switch data.direction {
            case .short: "Short"
            case .long: "Long"
            }
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
        case .transfer, .deposit, .perpetual: []
        case .stake(let validators, _): validators
        case .unstake(let delegation): [delegation.validator]
        case .redelegate(_, let validators, _): validators
        case .withdraw(let delegation): [delegation.validator]
        }
    }

    var stakeValidatorsType: StakeValidatorsType {
        switch type {
        case .transfer, .deposit, .perpetual, .stake, .redelegate: .stake
        case .unstake, .withdraw: .unstake
        }
    }

    var stakeValidatorViewModel: StakeValidatorViewModel? {
        guard let currentValidator else { return nil }
        return StakeValidatorViewModel(validator: currentValidator)
    }

    var delegations: [Delegation] {
        switch type {
        case .transfer, .deposit, .perpetual, .stake: []
        case .unstake(let delegation): [delegation]
        case .redelegate(let delegation, _, _): [delegation]
        case .withdraw(let delegation): [delegation]
        }
    }

    var isSelectValidatorEnabled: Bool {
        switch type {
        case .transfer, .deposit, .perpetual, .stake, .redelegate: true
        case .unstake, .withdraw: false
        }
    }
}

// MARK: - Business Logic

extension AmountSceneViewModel {
    func onAppear() {
        if canChangeValue {
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

    func onSelectInputButton() {
        switch amountInputType {
        case .asset: amountInputType = .fiat
        case .fiat: amountInputType = .asset
        }
        cleanInput()
    }

    func infoAction(for error: Error) -> (() -> Void)? {
        guard let transferError = error as? TransferError,
              let infoSheet = transferError.infoSheet
        else {
            return nil
        }
        return { [weak self] in
            self?.onSelect(infoSheet: infoSheet)
        }
    }
}

// MARK: - Private

extension AmountSceneViewModel {
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
        let transfer = try getTransferData(value: value)
        onTransferAction?(transfer)
    }

    private func onSelectBuy() {
        let senderAddress = (try? wallet.account(for: input.asset.chain).address) ?? ""
        let assetAddress = AssetAddress(asset: asset, address: senderAddress)

        isPresentingSheet = .fiatConnect(
            assetAddress: assetAddress,
            walletId: wallet.walletId
        )
    }

    private func onSelect(infoSheet: InfoSheetType) {
        switch infoSheet {
        case .stakeMinimumAmount(let asset, _):
            isPresentingSheet = .infoAction(
                infoSheet,
                button: .action(
                    title: Localized.Asset.buyAsset(asset.feeAsset.symbol),
                    action: onSelectBuy
                )
            )
        default:
            break
        }
    }

    private var recipientData: RecipientData {
        switch type {
        case .transfer(recipient: let recipient):
            return recipient
        case .deposit(recipient: let recipient):
            return recipient
        case .perpetual(let recipient, _):
            return recipient
        case .stake,
             .unstake,
             .redelegate,
             .withdraw:
            let recipientAddress = amountService.getRecipientAddress(
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
        switch input.type {
        case .transfer,
            .deposit,
            .stake,
            .unstake,
            .redelegate,
            .withdraw:
                return [
                .amount(
                    source: source,
                    decimals: asset.decimals.asInt,
                    validators: [
                        PositiveValueValidator<BigInt>().silent,
                        MinimumValueValidator<BigInt>(minimumValue: minimumValue, asset: asset),
                        BalanceValueValidator<BigInt>(available: availableValue, asset: asset)
                    ]
                )
            ]
        case .perpetual:
            return [] //TODO: Perpetual.
        }
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

    private func getTransferData(value: BigInt) throws -> TransferData {
        switch type {
        case .transfer:
            return TransferData(
                type: .transfer(asset),
                recipientData: recipientData,
                value: value,
                canChangeValue: canChangeValue
            )
        case .deposit:
            return TransferData(
                type: .deposit(asset),
                recipientData: recipientData,
                value: value,
                canChangeValue: canChangeValue
            )
        case .perpetual(_, let perpetual):
            //TODO: Perpetual
            let price = ""
            let size = ""
            return TransferData(
                type: .perpetual(
                    asset, .open(
                        PerpetualConfirmData(
                            direction: perpetual.direction,
                            asset: perpetual.asset,
                            assetIndex: perpetual.assetIndex,
                            price: price,
                            size: size
                        )
                    )
                ),
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
        try? amountService.getPrice(for: asset.id)
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
        case .deposit:
            // For deposits, require minimum 5 USDC
            if asset.symbol == "USDC" {
                return BigInt(5_000_000) // 5 USDC with 6 decimals
            }
        case .unstake, .withdraw, .transfer, .perpetual:
            break
        }
        return BigInt(0)
    }

    private var defaultValidator: DelegationValidator? {
        let recommended: DelegationValidator? = switch type {
        case .stake(_, let recommendedValidator): recommendedValidator
        case .redelegate(_, _, let recommendedValidator): recommendedValidator
        case .transfer, .deposit, .perpetual, .unstake, .withdraw: .none
        }
        return recommended ?? validators.first
    }

    private var availableValue: BigInt {
        switch input.type {
        case .transfer, .deposit, .perpetual, .stake:
            guard let balance = try? amountService.getBalance(walletId: wallet.walletId, assetId: asset.id.identifier) else {
                return .zero
            }
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

    private var canChangeValue: Bool {
        switch type {
        case .transfer,
             .deposit,
             .perpetual,
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

extension TransferError {
    var infoSheet: InfoSheetType? {
        switch self {
        case .minimumAmount(let asset, let required):
            .stakeMinimumAmount(asset, required: required)
        case .invalidAmount, .invalidAddress:
            nil
        }
    }
}
