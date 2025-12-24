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
    private let numberSanitizer = NumberSanitizer()
    private let valueConverter = ValueConverter()
    private let perpetualFormatter = PerpetualFormatter(provider: .hypercore)

    private var amountInputType: AmountInputType = .asset {
        didSet { amountInputModel.update(validators: inputValidators) }
    }

    private var input: AmountInput
    var assetRequest: AssetRequest
    var assetData: AssetData = .empty

    var amountInputModel: InputValidationViewModel = .init()
    var amountTypeModel: AmountTypeModel
    var isPresentingSheet: AmountSheetType?

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
        self.amountTypeModel = AmountTypeModel.from(type: input.type, currencyFormatter: currencyFormatter)
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
}

// MARK: - Business Logic

extension AmountSceneViewModel {
    var shouldFocusOnAppear: Bool { canChangeValue }

    func onAppear() {
        if !canChangeValue {
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
    }

    func onSelectLeverage() {
        isPresentingSheet = .leverageSelector
    }

    func onSelectAutoclose() {
        guard let model = amountTypeModel.perpetual else { return }
        let transferData = model.transferData
        isPresentingSheet = .autoclose(AutocloseOpenData(
            assetId: transferData.asset.id,
            symbol: transferData.asset.symbol,
            direction: transferData.direction,
            marketPrice: transferData.price,
            leverage: model.selectedItem?.value ?? 1,
            size: currencyFormatter.double(from: amountInputModel.text) ?? .zero,
            assetDecimals: transferData.asset.decimals,
            takeProfit: model.takeProfit,
            stopLoss: model.stopLoss
        ))
    }

    func onAutocloseComplete(takeProfit: InputValidationViewModel, stopLoss: InputValidationViewModel) {
        amountTypeModel.perpetual?.takeProfit = takeProfit.text.isEmpty ? nil : takeProfit.text
        amountTypeModel.perpetual?.stopLoss = stopLoss.text.isEmpty ? nil : stopLoss.text
        isPresentingSheet = nil
    }

    func onSelectValidator(_ validator: DelegationValidator) {
        amountTypeModel.staking?.selectedItem = validator
    }

    func onSelectResource(_ resource: Primitives.Resource) {
        cleanInput()
        if let freezeModel = amountTypeModel.freeze {
            freezeModel.selectedItem = resource
            input = AmountInput(type: .freeze(data: freezeModel.currentFreezeData), asset: input.asset)
        }
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
        case .transfer(recipient: let recipient): return recipient
        case .deposit(recipient: let recipient): return recipient
        case .withdraw(recipient: let recipient): return recipient
        case .perpetual(let data): return data.recipient
        case .stake,
             .stakeUnstake,
             .stakeRedelegate,
             .stakeWithdraw:
            let validator = amountTypeModel.staking?.selectedItem
            let validatorAddress = validator.flatMap { recipientAddress(chain: asset.chain.stakeChain, validatorId: $0.id) } ?? ""
            return RecipientData(
                recipient: Recipient(
                    name: validator?.name,
                    address: validatorAddress,
                    memo: Localized.Stake.viagem
                ),
                amount: .none
            )
        case .freeze:
            let resource = amountTypeModel.freeze?.selectedItemViewModel
            return RecipientData(
                recipient: Recipient(
                    name: resource?.title ?? "",
                    address: resource?.title ?? "",
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
            let leverage = amountTypeModel.perpetual?.selectedItem?.value ?? 1
            let takeProfit = amountTypeModel.perpetual?.takeProfit
            let stopLoss = amountTypeModel.perpetual?.stopLoss
            let perpetualType = PerpetualOrderFactory().makePerpetualOrder(
                positionAction: data.positionAction,
                usdcAmount: value,
                usdcDecimals: asset.decimals.asInt,
                leverage: leverage,
                takeProfit: takeProfit.flatMap { currencyFormatter.double(from: $0) }.map { perpetualFormatter.formatPrice($0, decimals: decimals) },
                stopLoss: stopLoss.flatMap { currencyFormatter.double(from: $0) }.map { perpetualFormatter.formatPrice($0, decimals: decimals) }
            )
            return TransferData(
                type: .perpetual(data.positionAction.transferData.asset, perpetualType),
                recipientData: recipientData,
                value: value,
                canChangeValue: canChangeValue
            )
        case .stake:
            guard let validator = amountTypeModel.staking?.selectedItem else {
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
            guard let validator = amountTypeModel.staking?.selectedItem else {
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
            guard let freezeModel = amountTypeModel.freeze else {
                throw TransferError.invalidAmount
            }
            return TransferData(
                type: .stake(asset, .freeze(freezeModel.currentFreezeData)),
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
            let leverage = amountTypeModel.perpetual?.selectedItem?.value ?? 1
            return BigInt(
                perpetualFormatter.minimumOrderUsdAmount(
                    price: data.positionAction.transferData.price,
                    decimals: data.positionAction.transferData.asset.decimals,
                    leverage: leverage
                )
            )
        case .stakeUnstake, .transfer:
            break
        }
        return BigInt(0)
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
