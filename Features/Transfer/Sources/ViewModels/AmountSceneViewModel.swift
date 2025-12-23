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

        self.selectedLeverage = AmountLeverageViewModel.defaultLeverage(for: input.type)
        self.selectedResource = AmountResourceViewModel.defaultResource(for: input.type)
        self.currentValidator = AmountValidatorViewModel.defaultValidator(for: input.type)
        self.amountInputModel = InputValidationViewModel(mode: .onDemand, validators: inputValidators)

        let recipientAmount: String? = switch input.type {
        case .transfer(let recipient): recipient.amount
        case .deposit(let recipient): recipient.amount
        case .withdraw(let recipient): recipient.amount
        case .perpetual(let data): data.recipient.amount
        case .stake, .stakeUnstake, .stakeRedelegate, .stakeWithdraw, .freeze: nil
        }
        if let recipientAmount {
            amountInputModel.update(text: recipientAmount)
        }
    }

    var type: AmountType { input.type }
    var asset: Asset {
        input.asset
    }
    var isInputDisabled: Bool { !balanceViewModel.canChangeValue }

    var actionButtonState: ButtonState {
        amountInputModel.text.isNotEmpty && amountInputModel.isValid ? .normal : .disabled
    }

    var continueTitle: String { Localized.Common.continue }
    var nextTitle: String { Localized.Common.next }
    var isNextEnabled: Bool { actionButtonState == .normal }

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

    var perpetualViewModel: AmountPerpetualViewModel {
        AmountPerpetualViewModel(
            type: type,
            selectedLeverage: selectedLeverage,
            takeProfit: takeProfit.flatMap { currencyFormatter.double(from: $0) },
            stopLoss: stopLoss.flatMap { currencyFormatter.double(from: $0) }
        )
    }

    var balanceViewModel: AmountBalanceViewModel {
        AmountBalanceViewModel(type: type, assetData: assetData)
    }

    var validatorViewModel: AmountValidatorViewModel {
        AmountValidatorViewModel(type: type, currentValidator: currentValidator)
    }

    var resourceViewModel: AmountResourceViewModel {
        AmountResourceViewModel(type: type, selectedResource: selectedResource)
    }

    var infoViewModel: AmountInfoViewModel {
        AmountInfoViewModel(
            type: type,
            balanceViewModel: balanceViewModel,
            currentAmountText: amountInputModel.text
        )
    }
}

// MARK: - Business Logic

extension AmountSceneViewModel {
    func onAppear() {
        if balanceViewModel.canChangeValue {
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
        isPresentingSheet = .infoAction(.stakingReservedFees(image: balanceViewModel.assetImage))
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
        amountInputModel.update(text: balanceViewModel.maxBalanceText)
    }

    private func cleanInput() {
        amountInputModel.text = .empty
        amountInputModel.update(validators: inputValidators)
    }

    private func setSelectedValidator(_ validator: DelegationValidator) {
        currentValidator = validator
    }

    private func onNext() throws {
        let amountText = switch amountInputType {
        case .asset: amountInputModel.text
        case .fiat: amountValue
        }
        let value = try formatter.inputNumber(from: amountText, decimals: asset.decimals.asInt)
        let transferData = try TransferDataBuilder(
            input: input,
            balanceViewModel: balanceViewModel,
            validatorViewModel: validatorViewModel,
            resourceViewModel: resourceViewModel,
            perpetualViewModel: perpetualViewModel
        ).build(value: value)
        onTransferAction?(transferData)
    }

    private func onSelectBuy() {
        let senderAddress = (try? wallet.account(for: input.asset.chain).address) ?? ""
        let assetAddress = AssetAddress(asset: asset, address: senderAddress)

        isPresentingSheet = .fiatConnect(
            assetAddress: assetAddress,
            walletId: wallet.walletId
        )
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
                        BalanceValueValidator<BigInt>(available: balanceViewModel.availableValue, asset: asset)
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
            return perpetualViewModel.minimumOrderAmount
        case .stakeUnstake, .transfer:
            break
        }
        return BigInt(0)
    }
}

// MARK: - ListSectionProvideable

extension AmountSceneViewModel: ListSectionProvideable {
    public var sections: [ListSection<AmountItem>] {
        [
            ListSection(type: .input, [.input]),
            ListSection(type: .balance, [.balance]),
            ListSection(type: .info, [.info]),
            ListSection(type: .options, title: type.optionsSectionTitle, [.validator, .resource, .leverage, .autoclose])
        ]
    }

    public func itemModel(for item: AmountItem) -> any ItemModelProvidable<AmountItemModel> {
        switch item {
        case .input:
            AmountInputItemViewModel()
        case .balance:
            balanceViewModel
        case .info:
            infoViewModel
        case .validator:
            validatorViewModel
        case .resource:
            resourceViewModel
        case .leverage:
            perpetualViewModel.leverageViewModel
        case .autoclose:
            perpetualViewModel.autocloseViewModel
        }
    }
}
