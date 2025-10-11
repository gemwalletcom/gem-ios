// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI
import GemAPI
import Components
import Style
import Localization
import Store
import PrimitivesComponents
import Formatters
import Validators
import BigInt

@MainActor
@Observable
public final class FiatSceneViewModel {
    private static let minimumFiatAmount: Double = 5
    private static let maximumFiatAmount: Double = 10000

    private let fiatService: any GemAPIFiatService
    private let assetAddress: AssetAddress
    private let walletId: String

    private let amountFormatter: FiatAmountFormatter

    let currencyFormatter: CurrencyFormatter

    var assetData: AssetData = .empty
    var assetRequest: AssetRequest

    var state: StateViewType<[FiatQuote]> = .loading

    var input: FiatInput
    var inputValidationModel: InputValidationViewModel = InputValidationViewModel()

    var focusField: FiatScene.Field?
    var isPresentingFiatProvider: Bool = false

    public init(
        fiatService: any GemAPIFiatService = GemAPIService(),
        currencyFormatter: CurrencyFormatter = CurrencyFormatter(currencyCode: Currency.usd.rawValue),
        assetAddress: AssetAddress,
        walletId: String,
        type: FiatQuoteType = .buy
    ) {
        self.fiatService = fiatService
        self.currencyFormatter = currencyFormatter
        self.assetAddress = assetAddress
        self.walletId = walletId

        let buyAmount = FiatQuoteTypeViewModel(type: .buy).defaultAmount
        self.input = FiatInput(type: .buy, buyAmount: buyAmount)

        self.amountFormatter = FiatAmountFormatter(
            valueFormatter: ValueFormatter(locale: .US, style: .medium),
            decimals: assetAddress.asset.decimals.asInt
        )

        // TODO: - move asset request and query observing on top, just inject AssetData
        self.assetRequest = AssetRequest(walletId: walletId, assetId: assetAddress.asset.id)

        self.inputValidationModel = InputValidationViewModel(
            mode: .onDemand,
            validators: inputValidation
        )
        self.inputValidationModel.text = String(Int(buyAmount))
    }

    var title: String {
        switch input.type {
        case .buy: Localized.Buy.title(asset.name)
        case .sell: Localized.Sell.title(asset.name)
        }
    }
    
    var allowSelectProvider: Bool {
        state.value.or([]).count > 1
    }

    var currencyInputConfig: any CurrencyInputConfigurable {
        FiatCurrencyInputConfig(
            type: input.type,
            assetAddress: assetAddress,
            secondaryText: cryptoAmountValue
        )
    }

    var actionButtonTitle: String { Localized.Common.continue }
    var providerTitle: String { Localized.Common.provider }
    var rateTitle: String { Localized.Buy.rate }
    var errorTitle: String { Localized.Errors.errorOccured }
    var availableTitle: String { Localized.Asset.Balances.available }
    var emptyTitle: String { input.amount.isZero ? emptyAmountTitle : emptyQuotesTitle}
    var assetTitle: String { asset.name }

    var typeAmountButtonTitle: String {
        switch input.type {
        case .buy: Emoji.random
        case .sell: Localized.Transfer.max
        }
    }

    var typeAmountButtonStyle: ColorButtonStyle {
        switch input.type {
        case .buy: .amount()
        case .sell: .lightGray(paddingHorizontal: .small, paddingVertical: .small)
        }
    }

    var asset: Asset { assetAddress.asset }
    var assetImage: AssetImage { AssetIdViewModel(assetId: asset.id).assetImage }

    var suggestedAmounts: [Double] { typeModel(type: input.type).suggestedAmounts }

    var cryptoAmountValue: String {
        guard let quote = input.quote else { return "" }
        let quoteAmount = FiatQuoteViewModel(asset: asset, quote: quote, selectedQuote: nil, formatter: currencyFormatter).amountText
        return "≈ \(quoteAmount)"
    }
    
    var showFiatTypePicker: Bool {
        return assetData.balance.available > 0 && assetData.metadata.isSellEnabled
    }

    var assetBalance: String? {
        let text = balanceModel.availableBalanceText
        return text == .zero ? nil : text
    }

    var fiatProviderViewModel: FiatProvidersViewModel {
        FiatProvidersViewModel(state: fiatProvidersViewModelState)
    }

    func rateValue(for quote: FiatQuote) -> String {
        let quoteRate = FiatQuoteViewModel(asset: asset, quote: quote, selectedQuote: nil, formatter: currencyFormatter).rateText
        return "1 \(asset.symbol) ≈ \(quoteRate)"
    }

    func buttonTitle(amount: Double) -> String {
        switch input.type {
        case .buy: "\(currencyInputConfig.currencySymbol)\(Int(amount))"
        case .sell: "\(Int(amount))%"
        }
    }

    func pickerTitle(type: FiatQuoteType) -> String {
        typeModel(type: type).title
    }

    func providerAssetImage(_ provider: FiatProvider) -> AssetImage? {
        .resourceImage(image: provider.name.lowercased().replacing(" ", with: "_"))
    }
}

// MARK: - Business Logic

extension FiatSceneViewModel {
    func onSelectContinue() {
        guard let quote = input.quote,
              let url = URL(string: quote.redirectUrl) else { return }

        UIApplication.shared.open(url, options: [:])
    }

    func onSelect(amount: Double) {
        switch input.type {
        case .buy:
            inputValidationModel.text = amountFormatter.format(amount: amount, for: .buy)
        case .sell:
            let percentAmount = maxAmount * (amount / 100)
            inputValidationModel.text = amountFormatter.format(amount: percentAmount, for: .sell)
        }
    }

    func onSelectTypeAmount() {
        switch input.type {
        case .buy:
            let randomAmount = typeModel(type: input.type).randomAmount(maxAmount: maxAmount) ?? .zero
            inputValidationModel.text = amountFormatter.format(amount: randomAmount, for: .buy)
        case .sell:
            inputValidationModel.text = amountFormatter.format(amount: maxAmount, for: .sell)
        }
    }

    func onSelectFiatProviders() {
        isPresentingFiatProvider = true
    }

    func onSelectQuotes(_ quotes: [FiatQuoteViewModel]) {
        guard let quoteModel = quotes.first else { return }
        input.quote = quoteModel.quote
        isPresentingFiatProvider = false
    }

    func onChangeType(_: FiatQuoteType, type: FiatQuoteType) {
        inputValidationModel.text = amountFormatter.format(amount: input.amount, for: type)
        inputValidationModel.update(validators: inputValidation)
        focusField = type == .buy ? .amountBuy : .amountSell
    }

    func onChangeAmountValue(_ amount: Double) async {
        await fetch()
    }

    func onChangeAmountText(_: String, text: String) {
        input.amount = amountFormatter.parseAmount(from: text, for: input.type)
    }
}

// MARK: - Private

extension FiatSceneViewModel {
    private func fetch() async {
        input.quote = nil

        guard shouldProceedFetch else {
            state = .noData
            return
        }
        state = .loading

        do {
            let quotes: [FiatQuote] = try await {
                let request = FiatQuoteRequest(
                    assetId: asset.id.identifier,
                    type: input.type,
                    fiatCurrency: try Currency(id: currencyFormatter.currencyCode),
                    fiatAmount: input.type == .buy ? input.amount : nil,
                    cryptoValue: amountFormatter.formatCryptoValue(fiatAmount: input.amount, type: input.type),
                    walletAddress: assetAddress.address
                )
                return try await fiatService.getQuotes(asset: asset, request: request)
            }()

            if !quotes.isEmpty {
                input.quote = quotes.first
                state = .data(quotes)
            } else {
                state = .noData
            }
        } catch {
            if !error.isCancelled {
                state = .error(error)
                NSLog("FiatSceneViewModel get quotes error: \(error)")
            }
        }
    }

    private var emptyQuotesTitle: String { Localized.Buy.noResults }
    private var emptyAmountTitle: String {
        switch input.type {
        case .buy: Localized.Input.enterAmountTo(Localized.Wallet.buy)
        case .sell: Localized.Input.enterAmountTo(Localized.Wallet.sell)
        }
    }

    private var balanceModel: BalanceViewModel {
        BalanceViewModel(asset: asset, balance: assetData.balance, formatter: amountFormatter.valueFormatter)
    }

    private var maxAmount: Double {
        switch input.type {
        case .buy: FiatQuoteTypeViewModel.defaultBuyMaxAmount
        case .sell: balanceModel.availableBalanceAmount
        }
    }

    private var shouldProceedFetch: Bool {
        guard !input.amount.isZero else { return false }
        switch input.type {
        case .buy: return true
        case .sell: return input.amount <= maxAmount
        }
    }

    private var fiatProvidersViewModelState: StateViewType<SelectableListType<FiatQuoteViewModel>> {
        switch state {
        case .error(let error): .error(error)
        case .data(let items): .data(.plain(items.map { FiatQuoteViewModel(asset: asset, quote: $0, selectedQuote: input.quote, formatter: currencyFormatter) }))
        case .loading: .loading
        case .noData: .noData
        }
    }
    
    private var inputValidation: [any TextValidator] {
        switch input.type {
        case .buy:
            [
                .assetAmount(
                    decimals: 0,
                    validators: [FiatRangeValidator(
                        range: BigInt(Self.minimumFiatAmount)...BigInt(Self.maximumFiatAmount),
                        minimumValueText: currencyFormatter.string(Self.minimumFiatAmount),
                        maximumValueText: currencyFormatter.string(Self.maximumFiatAmount)
                    )]
                )
            ]
        case .sell: []
        }
    }

    private func typeModel(type: FiatQuoteType) -> FiatQuoteTypeViewModel {
        FiatQuoteTypeViewModel(type: type)
    }
}
