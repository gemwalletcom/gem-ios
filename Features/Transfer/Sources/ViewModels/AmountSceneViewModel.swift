// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Blockchain
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

@MainActor
@Observable
public final class AmountSceneViewModel {
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

    private var input: AmountInput
    var assetRequest: AssetRequest
    var assetData: AssetData = .empty

    var amountInputModel: InputValidationViewModel = .init()
    var delegation: DelegationValidator?
    var selectedResource: Primitives.Resource = .bandwidth {
        didSet {
            onSelectResource(selectedResource)
        }
    }

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

        // Initialize selectedResource based on current resource
        if let currentResource = currentResource {
            self.selectedResource = currentResource
        }

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
    var resourceTitle: String { Localized.Stake.resource }
    var maxTitle: String { Localized.Transfer.max }
    var nextTitle: String { Localized.Common.next }
    var continueTitle: String { Localized.Common.continue }
    var isNextEnabled: Bool { actionButtonState == .normal }

    var infoText: String? {
        switch type {
        case .transfer, .deposit, .withdraw, .stakeUnstake, .stakeRedelegate, .stakeWithdraw, .perpetual:
            return nil
        case .stake, .freeze:
            guard reservedForFee > .zero else { return nil }
            guard let inputValue = try? formatter.inputNumber(from: amountInputModel.text, decimals: asset.decimals.asInt) else { return nil }
            guard inputValue >= availableBalanceForStaking, inputValue <= availableValue else { return nil }
            return Localized.Transfer.reservedFees(formatter.string(reservedForFee, asset: asset))
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
        case .freeze(let data):
            switch data.freezeType {
            case .freeze: Localized.Transfer.Freeze.title
            case .unfreeze: Localized.Transfer.Unfreeze.title
            }
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
        case .transfer, .deposit, .withdraw, .perpetual, .freeze: []
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
        case .freeze: fatalError("unsupported")
        }
    }

    var stakeValidatorViewModel: StakeValidatorViewModel? {
        guard let currentValidator else { return nil }
        return StakeValidatorViewModel(validator: currentValidator)
    }

    var tronResourceViewModel: ResourceViewModel? {
        guard let currentResource else { return nil }
        return ResourceViewModel(resource: currentResource)
    }

    var availableResources: [ResourceViewModel] {
        [.bandwidth, .energy].map { ResourceViewModel(resource: $0) }
    }

    var currentResource: Primitives.Resource? {
        switch type {
        case .freeze(let data): data.resource
        default: nil
        }
    }

    var freezeType: Primitives.FreezeType? {
        switch type {
        case .freeze(let data): data.freezeType
        default: nil
        }
    }

    var delegations: [Delegation] {
        switch type {
        case .transfer, .deposit, .withdraw, .perpetual, .stake, .freeze: []
        case .stakeUnstake(let delegation): [delegation]
        case .stakeRedelegate(let delegation, _, _): [delegation]
        case .stakeWithdraw(let delegation): [delegation]
        }
    }

    var isSelectValidatorEnabled: Bool {
        switch type {
        case .transfer, .deposit, .withdraw, .perpetual, .stake, .stakeRedelegate: true
        case .stakeUnstake, .stakeWithdraw, .freeze: false
        }
    }

    var isSelectResourceEnabled: Bool {
        switch type {
        case .freeze: true
        case .transfer, .deposit, .withdraw, .perpetual, .stake, .stakeRedelegate, .stakeUnstake, .stakeWithdraw: false
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

    func onSelectResource(_ resource: Primitives.Resource) {
        guard case .freeze(let data) = type else { return }
        cleanInput()
        input = AmountInput(
            type: .freeze(
                data: data.with(resource: resource)
            ),
            asset: input.asset
        )
    }

    func onSelectInputButton() {
        switch amountInputType {
        case .asset: amountInputType = .fiat
        case .fiat: amountInputType = .asset
        }
        cleanInput()
    }

    func onSelectReservedFeesInfo() {
        isPresentingSheet = .infoAction(.stakingReservedFees(image: assetImage))
    }

    func infoAction(for error: Error) -> (() -> Void)? {
        guard let transferError = error as? TransferError,
              case .minimumAmount(let asset, let required) = transferError
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
        case .cosmos, .osmosis, .injective, .sei, .celestia, .solana, .sui, .tron, .smartChain, .ethereum: validatorId
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
        case .freeze(let data):
             RecipientData(
                recipient: Recipient(
                    name: ResourceViewModel(resource: data.resource).title,
                    address: ResourceViewModel(resource: data.resource).title,
                    memo: nil
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
            .perpetual,
            .freeze:
                return [
                .amount(
                    source: source,
                    decimals: asset.decimals.asInt,
                    validators: [
                        PositiveValueValidator<BigInt>().silent,
                        MinimumValueValidator<BigInt>(minimumValue: minimumValue + reservedForFee, asset: asset),
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
        case .freeze:
            // Use input.type to get the current resource selection
            guard case .freeze(let data) = input.type else {
                throw TransferError.invalidAmount
            }
            return TransferData(
                type: .stake(asset, .freeze(data)),
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
        case .freeze(let data):
            switch data.freezeType {
            case .freeze: return BigInt(StakeConfig.config(chain: stakeChain!).minAmount)
            case .unfreeze: return .zero
            }
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
            // For staking withdrawals, require minimum 5 USDC
            if asset.symbol == "USDC" {
                return BigInt(5_000_000) // 5 USDC with 6 decimals
            }
        case .withdraw:
            if asset.symbol == "USDC" {
                // withdrawals require a minimum of 2 USDC
                return BigInt(2_000_000)
            }
        case .perpetual:
            return BigInt(12_000_000) // 15 USDC with 6 decimals
        case .stakeUnstake, .transfer:
            break
        }
        return BigInt(0)
    }

    private var defaultValidator: DelegationValidator? {
        let recommended: DelegationValidator? = switch type {
        case .stake(_, let recommendedValidator): recommendedValidator
        case .stakeRedelegate(_, _, let recommendedValidator): recommendedValidator
        case .transfer, .deposit, .withdraw, .perpetual, .stakeUnstake, .stakeWithdraw, .freeze: .none
        }
        return recommended ?? validators.first
    }

    private var availableValue: BigInt {
        switch input.type {
        case .transfer, .deposit, .perpetual:
            return assetData.balance.available
        case .stake:
            if asset.chain == .tron {
                let staked = BigNumberFormatter.standard.number(from: Int(assetData.balance.metadata?.votes ?? 0), decimals: Int(assetData.asset.decimals))
                return (assetData.balance.frozen + assetData.balance.locked) - staked
            }
            return assetData.balance.available
        case .freeze(let data):
            switch data.freezeType {
            case .freeze: return assetData.balance.available
            case .unfreeze:
                switch data.resource {
                case .bandwidth: return assetData.balance.frozen
                case .energy: return assetData.balance.locked
                }
            }
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
        let maxValue: BigInt = switch input.type {
        case .transfer, .deposit, .withdraw, .perpetual, .stakeUnstake, .stakeRedelegate, .stakeWithdraw:
            availableValue
        case .stake:
            availableBalanceForStaking
        case .freeze(let data):
            switch data.freezeType {
            case .freeze: availableBalanceForStaking
            case .unfreeze: availableValue
            }
        }
        return formatter.string(maxValue, decimals: asset.decimals.asInt)
    }

    private var canChangeValue: Bool {
        switch type {
        case .transfer,
             .deposit,
             .withdraw,
             .perpetual,
             .stake,
             .stakeRedelegate,
             .freeze:
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
        let amountInputValue: String = switch amountInputType {
        case .asset: amountInputModel.text
        case .fiat: amountValue
        }

        // For stake/freeze, cap input at max allowed (balance - reserved fees)
        switch input.type {
        case .transfer, .deposit, .withdraw, .perpetual, .stakeUnstake, .stakeRedelegate, .stakeWithdraw:
            return amountInputValue
        case .stake, .freeze:
            guard let inputValue = try? formatter.inputNumber(from: amountInputValue, decimals: asset.decimals.asInt) else {
                return amountInputValue
            }
            if inputValue > availableBalanceForStaking {
                return formatter.string(availableBalanceForStaking, decimals: asset.decimals.asInt)
            }
            return amountInputValue
        }
    }

    private var minimumAccountReserve: BigInt {
        asset.type == .native ? asset.chain.minimumAccountBalance : .zero
    }

    private var reservedForFee: BigInt {
        switch input.type {
        case .transfer, .deposit, .withdraw, .perpetual, .stakeUnstake, .stakeRedelegate, .stakeWithdraw: .zero
        case .stake: BigInt(Config.shared.getStakeConfig(chain: asset.chain.rawValue).reservedForFees)
        case .freeze(let data):
            switch data.freezeType {
            case .freeze: BigInt(Config.shared.getStakeConfig(chain: asset.chain.rawValue).reservedForFees)
            case .unfreeze: .zero
            }
        }
    }

    private var availableBalanceForStaking: BigInt {
        assetData.balance.available > reservedForFee
        ? assetData.balance.available - reservedForFee
        : .zero
    }
}
