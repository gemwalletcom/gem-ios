// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Components
import Formatters
import Foundation
import Gemstone
import GemstonePrimitives
import InfoSheet
import Localization
import Preferences
import Primitives
import PrimitivesComponents
import Staking
import Store
import Style
import Validators
import WalletsService
import Blockchain

@MainActor
@Observable
public final class AmountSceneViewModel {
    private let input: AmountInput
    private let wallet: Wallet

    private let onTransferAction: TransferDataAction

    private let formatter = ValueFormatter(style: .full)
    private let currencyFormatter = CurrencyFormatter(type: .currency, currencyCode: Preferences.standard.currency)
    private let numberSanitizer = NumberSanitizer()
    private let valueConverter = ValueConverter()
    private let perpetualPriceFormatter = PerpetualPriceFormatter()

    private var currentValidator: DelegationValidator?
    private var amountInputType: AmountInputType = .asset {
        didSet { amountInputModel.update(validators: inputValidators) }
    }

    var assetRequest: AssetRequest
    var assetData: AssetData = .empty

    var amountInputModel: InputValidationViewModel = InputValidationViewModel()
    var delegation: DelegationValidator?
    var isPresentingSheet: AmountSheetType?
    var focusField: Bool = false

    public init(
        input: AmountInput,
        wallet: Wallet,
        onTransferAction: TransferDataAction
    ) {
        self.input = input
        self.wallet = wallet
        self.onTransferAction = onTransferAction
        self.assetRequest = AssetRequest(
            walletId: wallet.walletId.id,
            assetId: input.asset.id
        )

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

    var actionButtonState: ButtonState {
        amountInputModel.text.isNotEmpty && amountInputModel.isValid ? .normal : .disabled
    }

    var validatorTitle: String { Localized.Stake.validator }
    var maxTitle: String { Localized.Transfer.max }
    var nextTitle: String { Localized.Common.next }
    var continueTitle: String { Localized.Common.continue }
    var isNextEnabled: Bool { actionButtonState == .normal }
    
    var infoText: String? {
        switch type {
        case .transfer, .deposit, .withdraw, .stakeUnstake, .stakeRedelegate, .stakeWithdraw, .perpetual:
            return nil
        case .stake:
            guard amountInputModel.text == maxBalance, availableBalanceForStaking > .zero else { return nil }
            return Localized.Transfer.reservedFees(formatter.string(stakingReservedForFees, asset: asset))
        }
    }

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
        case .deposit: Localized.Wallet.deposit
        case .withdraw: Localized.Wallet.withdraw
        case .perpetual(_, let data):
            switch data.direction {
            case .short: "Short"
            case .long: "Long"
            }
        case .stake: Localized.Transfer.Stake.title
        case .stakeUnstake: Localized.Transfer.Unstake.title
        case .stakeRedelegate: Localized.Transfer.Redelegate.title
        case .stakeWithdraw: Localized.Transfer.Withdraw.title
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
        case .transfer, .deposit, .withdraw, .perpetual: []
        case .stake(let validators, _): validators
        case .stakeUnstake(let delegation): [delegation.validator]
        case .stakeRedelegate(_, let validators, _): validators
        case .stakeWithdraw(let delegation): [delegation.validator]
        }
    }

    var stakeValidatorsType: StakeValidatorsType {
        switch type {
        case .transfer, .deposit, .withdraw, .perpetual, .stake, .stakeRedelegate: .stake
        case .stakeUnstake, .stakeWithdraw: .unstake
        }
    }

    var stakeValidatorViewModel: StakeValidatorViewModel? {
        guard let currentValidator else { return nil }
        return StakeValidatorViewModel(validator: currentValidator)
    }

    var delegations: [Delegation] {
        switch type {
        case .transfer, .deposit, .withdraw, .perpetual, .stake: []
        case .stakeUnstake(let delegation): [delegation]
        case .stakeRedelegate(let delegation, _, _): [delegation]
        case .stakeWithdraw(let delegation): [delegation]
        }
    }

    var isSelectValidatorEnabled: Bool {
        switch type {
        case .transfer, .deposit, .withdraw, .perpetual, .stake, .stakeRedelegate: true
        case .stakeUnstake, .stakeWithdraw: false
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

    func onChangeAssetBalance(_: AssetData, _: AssetData) {
        amountInputModel.update(validators: inputValidators)
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
              case let .minimumAmount(asset, required) = transferError
        else {
            return nil
        }
        return { [weak self] in
            guard let self else { return }
            self.isPresentingSheet = .infoAction(.stakeMinimumAmount(asset, required: required, action: self.onSelectBuy))
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

    private func recipientAddress(chain: StakeChain?, validatorId: String) -> String {
        switch chain {
        case .cosmos, .osmosis, .injective, .sei, .celestia, .solana, .sui, .tron, .smartChain: validatorId
        case .none, .some(.hyperCore): ""
        }
    }
    
    private var recipientData: RecipientData {
        switch type {
        case .transfer(recipient: let recipient): recipient
        case .deposit(recipient: let recipient): recipient
        case .withdraw(recipient: let recipient): recipient
        case .perpetual(let recipient, _): recipient
        case .stake,
             .stakeUnstake,
             .stakeRedelegate,
             .stakeWithdraw: RecipientData(
                recipient: Recipient(
                    name: currentValidator?.name,
                    address: (currentValidator?.id).flatMap { recipientAddress(chain: asset.chain.stakeChain, validatorId: $0) } ?? "",
                    memo: Localized.Stake.viagem
                ),
                amount: .none
            )
        }
    }

    private var inputValidators: [any TextValidator] {
        let source: AmountValidator.Source = switch amountInputType {
        case .asset: .asset
        case .fiat: .fiat(price: assetData.price?.mapToAssetPrice(assetId: asset.id), converter: valueConverter)
        }
        switch input.type {
        case .transfer,
            .deposit,
            .withdraw,
            .stake,
            .stakeUnstake,
            .stakeRedelegate,
            .stakeWithdraw,
            .perpetual:
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
        }
    }

    private var fiatValueText: String {
        currencyFormatter.string(fiatValue.doubleValue)
    }

    private var amountValueText: String {
        [amountValue, asset.symbol].joined(separator: " ")
    }

    private var amountValue: String {
        guard let price = assetData.price else { return .zero }
        return (try? valueConverter.convertToAmount(
            fiatValue: amountInputModel.text,
            price: price.mapToAssetPrice(assetId: asset.id),
            decimals: asset.decimals.asInt
        )).or(.zero)
    }

    private var fiatValue: Decimal {
        guard let price = assetData.price else { return .zero }
        return (try? valueConverter.convertToFiat(
            amount: amountInputModel.text,
            price: price.mapToAssetPrice(assetId: asset.id)
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
        case .withdraw:
            return TransferData(
                type: .withdrawal(asset),
                recipientData: recipientData,
                value: value,
                canChangeValue: canChangeValue
            )
        case .perpetual(_, let perpetual):
            // Add 2% slippage for market-like execution
            // For long: buy 2% above market (more conservative)
            // For short: sell 2% below market (more conservative)
            let slippagePrice = switch perpetual.direction {
            case .long: perpetual.price * 1.02
            case .short: perpetual.price * 0.98
            }
            let price = perpetualPriceFormatter.formatPrice(
                provider: perpetual.provider,
                slippagePrice,
                decimals: perpetual.perpetualAsset.decimals.asInt
            )
            // Convert USDC amount to USD value
            let usdAmount = Double(value) / pow(10.0, Double(asset.decimals))
            // Size = (USD amount * leverage) / price (use original price for size calculation)
            let sizeAsAsset = (usdAmount * Double(perpetual.leverage)) / perpetual.price
            let size = perpetualPriceFormatter.formatSize(
                provider: perpetual.provider,
                sizeAsAsset,
                decimals: Int(perpetual.perpetualAsset.decimals)
            )
            return TransferData(
                type: .perpetual(
                    asset, .open(
                        PerpetualConfirmData(
                            direction: perpetual.direction,
                            asset: perpetual.asset,
                            assetIndex: Int32(perpetual.assetIndex),
                            price: price,
                            fiatValue: perpetual.price * sizeAsAsset,
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
                type: .stake(asset, .stake(validator)),
                recipientData: recipientData,
                value: value,
                canChangeValue: canChangeValue
            )
        case .stakeUnstake(let delegation):
            return TransferData(
                type: .stake(asset, .unstake(delegation)),
                recipientData: recipientData,
                value: value,
                canChangeValue: canChangeValue
            )
        case .stakeRedelegate(let delegation, _, _):
            guard let validator = currentValidator else {
                throw TransferError.invalidAmount
            }
            return TransferData(
                type: .stake(asset, .redelegate(RedelegateData(delegation: delegation, toValidator: validator))),
                recipientData: recipientData,
                value: value,
                canChangeValue: canChangeValue
            )
        case .stakeWithdraw(let delegation):
            return TransferData(
                type: .stake(asset, .withdraw(delegation)),
                recipientData: recipientData,
                value: value,
                canChangeValue: canChangeValue
            )
        }
    }

    private func value(for amount: String) throws -> BigInt {
        try formatter.inputNumber(from: amount, decimals: asset.decimals.asInt)
    }

    private var minimumValue: BigInt {
        let stakeChain = asset.chain.stakeChain
        switch type {
        case .stake:
            return BigInt(StakeConfig.config(chain: stakeChain!).minAmount)
        case .stakeRedelegate:
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
        case .stakeWithdraw:
            // For withdrawals, require minimum 5 USDC
            if asset.symbol == "USDC" {
                return BigInt(5_000_000) // 5 USDC with 6 decimals
            }
        case .perpetual:
            return BigInt(12_000_000) // 15 USDC with 6 decimals
        case .stakeUnstake, .withdraw, .transfer:
            break
        }
        return BigInt(0)
    }

    private var defaultValidator: DelegationValidator? {
        let recommended: DelegationValidator? = switch type {
        case .stake(_, let recommendedValidator): recommendedValidator
        case .stakeRedelegate(_, _, let recommendedValidator): recommendedValidator
        case .transfer, .deposit, .withdraw, .perpetual, .stakeUnstake, .stakeWithdraw: .none
        }
        return recommended ?? validators.first
    }

    private var availableValue: BigInt {
        switch input.type {
        case .transfer, .deposit, .perpetual:
            return assetData.balance.available
        case .stake:
            return availableBalanceForStaking
        case .withdraw:
            return assetData.balance.withdrawable
        case .stakeUnstake(let delegation):
            return delegation.base.balanceValue
        case .stakeRedelegate(let delegation, _, _):
            return delegation.base.balanceValue
        case .stakeWithdraw(let delegation):
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
             .withdraw,
             .perpetual,
             .stake,
             .stakeRedelegate:
            return true
        case .stakeUnstake:
            if let chain = StakeChain(rawValue: asset.chain.rawValue) {
                return chain.canChangeAmountOnUnstake
            }
            return true
        case .stakeWithdraw:
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
    
    private var stakingReservedForFees: BigInt {
        BigInt(Config.shared.getStakeConfig(chain: asset.chain.rawValue).reservedForFees)
    }
    
    private var availableBalanceForStaking: BigInt {
        assetData.balance.available > stakingReservedForFees
        ? assetData.balance.available - stakingReservedForFees
        : .zero
    }
}
