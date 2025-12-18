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
import PerpetualService
import Perpetuals

@MainActor
@Observable
public final class AmountSceneViewModel {
    private let wallet: Wallet
    private let onTransferAction: TransferDataAction
    private let preferences: Preferences

    private let formatter = ValueFormatter(style: .full)
    private let currencyFormatter = CurrencyFormatter(type: .currency, currencyCode: Preferences.standard.currency)
    private let autocloseFormatter = AutocloseFormatter()
    private let numberSanitizer = NumberSanitizer()
    private let valueConverter = ValueConverter()
    private let perpetualFormatter = PerpetualFormatter(provider: .hypercore)

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
    var selectedLeverage: LeverageOption = LeverageOption(value: 1) {
        didSet {
            amountInputModel.update(validators: inputValidators)
        }
    }
    var takeProfit: String?
    var stopLoss: String?

    var isPresentingSheet: AmountSheetType?
    var focusField: Bool = false

    public init(
        input: AmountInput,
        wallet: Wallet,
        preferences: Preferences = .standard,
        onTransferAction: TransferDataAction
    ) {
        self.input = input
        self.wallet = wallet
        self.preferences = preferences
        self.onTransferAction = onTransferAction
        self.assetRequest = AssetRequest(
            walletId: wallet.walletId.id,
            assetId: input.asset.id
        )

        if case .perpetual(let data) = type {
            switch data.positionAction {
            case .open:
                self.selectedLeverage = LeverageOption.option(
                    desiredValue: Preferences.standard.perpetualLeverage,
                    from: leverageOptions
                )
            case .increase, .reduce:
                self.selectedLeverage = LeverageOption(value: data.positionAction.transferData.leverage)
            }
        }

        if let currentResource = currentResource {
            self.selectedResource = currentResource
        }

        self.currentValidator = defaultValidator
        self.amountInputModel = InputValidationViewModel(mode: .onDemand, validators: inputValidators)

        if let recipientAmount = recipientData.amount {
            amountInputModel.update(text: recipientAmount)
        }
    }

    var type: AmountType { input.type }
    var asset: Asset {
        input.asset
    }
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
            guard shouldReserveFee, amountInputModel.text == maxBalance else { return nil }
            return Localized.Transfer.reservedFees(formatter.string(reserveForFee, asset: asset))
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
        case .perpetual(let data):
            switch data.positionAction {
            case .open(let data): PerpetualDirectionViewModel(direction: data.direction).title
            case .increase(let data): PerpetualDirectionViewModel(direction: data.direction).increaseTitle
            case .reduce(_, _, let direction): PerpetualDirectionViewModel(direction: direction).reduceTitle
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

    var isPerpetualLeverageEnabled: Bool {
        switch type {
        case .perpetual(let data):
            switch data.positionAction {
            case .open: true
            case .increase, .reduce: false
            }
        case .transfer, .deposit, .withdraw, .stake, .stakeRedelegate, .stakeUnstake, .stakeWithdraw, .freeze: false
        }
    }

    var maxLeverage: UInt8 {
        switch type {
        case .perpetual(let data): data.positionAction.transferData.leverage
        case .transfer, .deposit, .withdraw, .stake, .stakeRedelegate, .stakeUnstake, .stakeWithdraw, .freeze: .zero
        }
    }

    var leverageOptions: [LeverageOption] {
        LeverageOption.allOptions.filter { $0.value <= maxLeverage }
    }
    var leverageTitle: String { Localized.Perpetual.leverage }
    var leverageText: String { selectedLeverage.displayText }
    var leverageTextStyle: TextStyle {
        guard case .perpetual(let data) = type,
              case .open(let transferData) = data.positionAction
        else {
            return .callout
        }
        return TextStyle(
            font: .callout,
            color: PerpetualDirectionViewModel(direction: transferData.direction).color
        )
    }

    var isAutocloseEnabled: Bool {
        switch type {
        case .perpetual(let data):
            switch data.positionAction {
            case .open: true
            case .increase, .reduce: false
            }
        case .transfer, .deposit, .withdraw, .stake, .stakeRedelegate, .stakeUnstake, .stakeWithdraw, .freeze: false
        }
    }

    var autocloseTitle: String { Localized.Perpetual.autoClose }
    var autocloseText: (subtitle: String, subtitleExtra: String?) {
        autocloseFormatter.format(
            takeProfit: takeProfit.flatMap { currencyFormatter.double(from: $0) },
            stopLoss: stopLoss.flatMap { currencyFormatter.double(from: $0) }
        )
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

    func onSelectLeverage() {
        isPresentingSheet = .leverageSelector
    }

    func onSelectAutoclose() {
        guard case .perpetual(let data) = type else { return }
        let transferData = data.positionAction.transferData
        isPresentingSheet = .autoclose(AutocloseOpenData(
            assetId: transferData.asset.id,
            symbol: transferData.asset.symbol,
            direction: transferData.direction,
            marketPrice: transferData.price,
            leverage: selectedLeverage.value,
            size: currencyFormatter.double(from: amountInputModel.text) ?? .zero,
            assetDecimals: transferData.asset.decimals,
            takeProfit: takeProfit,
            stopLoss: stopLoss
        ))
    }

    func onAutocloseComplete(takeProfit: InputValidationViewModel, stopLoss: InputValidationViewModel) {
        self.takeProfit = takeProfit.text.isEmpty ? nil : takeProfit.text
        self.stopLoss = stopLoss.text.isEmpty ? nil : stopLoss.text
        isPresentingSheet = nil
    }

    func onSelectValidator(_ validator: DelegationValidator) {
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
        amountInputModel.update(validators: inputValidators)
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
        case .cosmos, .osmosis, .injective, .sei, .celestia, .solana, .sui, .tron, .smartChain, .ethereum, .aptos, .monad: validatorId
        case .none, .some(.hyperCore): ""
        }
    }

    private var recipientData: RecipientData {
        switch type {
        case .transfer(recipient: let recipient): recipient
        case .deposit(recipient: let recipient): recipient
        case .withdraw(recipient: let recipient): recipient
        case .perpetual(let data): data.recipient
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
        case .perpetual(let data):
            let decimals = data.positionAction.transferData.asset.decimals
            let perpetualType = PerpetualOrderFactory().makePerpetualOrder(
                positionAction: data.positionAction,
                usdcAmount: value,
                usdcDecimals: asset.decimals.asInt,
                leverage: selectedLeverage.value,
                takeProfit: takeProfit.flatMap { currencyFormatter.double(from: $0) }.map { perpetualFormatter.formatPrice($0, decimals: decimals) },
                stopLoss: stopLoss.flatMap { currencyFormatter.double(from: $0) }.map { perpetualFormatter.formatPrice($0, decimals: decimals) },
                autocloseOrderType: .market
            )
            return TransferData(
                type: .perpetual(data.positionAction.transferData.asset, perpetualType),
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
        case .perpetual(let data):
            return BigInt(
                perpetualFormatter.minimumOrderUsdAmount(
                    price: data.positionAction.transferData.price,
                    decimals: data.positionAction.transferData.asset.decimals,
                    leverage: selectedLeverage.value
                )
            )
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
        case .transfer, .deposit:
            return assetData.balance.available
        case let .perpetual(perpetualData):
            switch perpetualData.positionAction {
            case .open, .increase: return assetData.balance.available
            case .reduce(_, let available, _): return available
            }
        case .stake:
            switch asset.chain {
            case .tron:
                let staked = BigNumberFormatter.standard.number(from: Int(assetData.balance.metadata?.votes ?? 0), decimals: Int(assetData.asset.decimals))
                return (assetData.balance.frozen + assetData.balance.locked) - staked
            default: return assetData.balance.available
            }
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
            switch asset.chain {
            case .tron: availableValue
            default: shouldReserveFee ? availableBalanceForMaxStaking : availableValue
            }
        case .freeze(let data):
            switch data.freezeType {
            case .freeze: shouldReserveFee ? availableBalanceForMaxStaking : availableValue
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
        switch amountInputType {
        case .asset: amountInputModel.text
        case .fiat: amountValue
        }
    }

    private var minimumAccountReserve: BigInt {
        asset.type == .native ? asset.chain.minimumAccountBalance : .zero
    }
    
    private var shouldReserveFee: Bool {
        switch input.type {
        case .transfer, .deposit, .withdraw, .perpetual, .stakeUnstake, .stakeRedelegate, .stakeWithdraw: false
        case .stake:
            switch asset.chain {
            case .tron: false
            default: availableBalanceForMaxStaking > minimumValue && reserveForFee.isZero == false
            }
        case .freeze(let data):
            switch data.freezeType {
            case .freeze: availableBalanceForMaxStaking > minimumValue
            case .unfreeze: false
            }
        }
    }

    private var reserveForFee: BigInt {
        switch input.type {
        case .transfer, .deposit, .withdraw, .perpetual, .stakeUnstake, .stakeRedelegate, .stakeWithdraw: .zero
        case .stake:
            switch asset.chain {
            case .tron: .zero
            default: BigInt(Config.shared.getStakeConfig(chain: asset.chain.rawValue).reservedForFees)
            }
        case .freeze(let data):
            switch data.freezeType {
            case .freeze: BigInt(Config.shared.getStakeConfig(chain: asset.chain.rawValue).reservedForFees)
            case .unfreeze: .zero
            }
        }
    }

    private var availableBalanceForMaxStaking: BigInt {
        max(.zero, availableValue - reserveForFee)
    }
}
