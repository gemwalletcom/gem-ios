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
import Preferences

@MainActor
@Observable
public final class FiatSceneViewModel {
    private struct Constants {
        static let randomMaxAmount: Int = 1000
        static let defaultAmount: Int = 50
        static let suggestedAmounts: [Int] = [100, 250]
    }

    private let fiatService: any GemAPIFiatService
    private let securePreferences: SecurePreferences
    private let assetAddress: AssetAddress

    private let currencyFormatter: CurrencyFormatter
    private let valueFormatter = ValueFormatter(locale: .US, style: .medium)

    var assetData: AssetData = .empty
    var assetRequest: AssetRequest

    private let buyContext = FiatOperationContext()
    private let sellContext = FiatOperationContext()

    private let buyStrategy: FiatOperationStrategy
    private let sellStrategy: FiatOperationStrategy

    var urlState: StateViewType<Void> = .noData
    var type: FiatQuoteType
    var inputValidationModel: InputValidationViewModel = InputValidationViewModel()

    var isPresentingFiatProvider: Bool = false

    public init(
        fiatService: any GemAPIFiatService = GemAPIService(),
        securePreferences: SecurePreferences = SecurePreferences(),
        currencyFormatter: CurrencyFormatter = CurrencyFormatter(currencyCode: Currency.usd.rawValue),
        assetAddress: AssetAddress,
        walletId: String,
        type: FiatQuoteType = .buy
    ) {
        self.fiatService = fiatService
        self.securePreferences = securePreferences
        self.currencyFormatter = currencyFormatter
        self.assetAddress = assetAddress
        self.type = type
        self.assetRequest = AssetRequest(walletId: walletId, assetId: assetAddress.asset.id)

        self.buyStrategy = BuyFiatStrategy(
            service: fiatService,
            asset: assetAddress.asset,
            currencyFormatter: currencyFormatter
        )
        self.sellStrategy = SellFiatStrategy(
            service: fiatService,
            asset: assetAddress.asset,
            currencyFormatter: currencyFormatter
        )

        self.inputValidationModel = InputValidationViewModel(
            mode: .onDemand,
            validators: []
        )
        self.inputValidationModel.text = context.amount
        updateValidators()
    }

    private var context: FiatOperationContext {
        switch type {
        case .buy: buyContext
        case .sell: sellContext
        }
    }

    private var strategy: FiatOperationStrategy {
        switch type {
        case .buy: buyStrategy
        case .sell: sellStrategy
        }
    }

    var quotesState: StateViewType<[FiatQuote]> {
        get { context.quotesState }
        set { context.quotesState = newValue }
    }

    var selectedQuote: FiatQuote? {
        get { context.selectedQuote }
        set { context.selectedQuote = newValue }
    }

    var title: String {
        switch type {
        case .buy: Localized.Buy.title(asset.name)
        case .sell: Localized.Sell.title(asset.name)
        }
    }
    
    var allowSelectProvider: Bool {
        quotesState.value.or([]).count > 1
    }

    var currencyInputConfig: any CurrencyInputConfigurable {
        FiatCurrencyInputConfig(secondaryText: cryptoAmountValue, currencySymbol: currencyFormatter.symbol)
    }

    var actionButtonTitle: String { Localized.Common.continue }
    var actionButtonState: StateViewType<[FiatQuote]> {
        if selectedQuote == nil { return .noData }
        if urlState.isLoading { return .loading }
        if inputValidationModel.isInvalid || inputValidationModel.text.isEmptyOrZero { return .noData }
        return quotesState
    }
    var providerTitle: String { Localized.Common.provider }
    var rateTitle: String { Localized.Buy.rate }
    var errorTitle: String { Localized.Errors.errorOccured }
    var emptyTitle: String { inputValidationModel.text.isEmptyOrZero ? emptyAmountTitle : Localized.Buy.noResults}
    var assetTitle: String { asset.name }
    var typeAmountButtonTitle: String { Emoji.random }
    var asset: Asset { assetAddress.asset }
    var assetImage: AssetImage { AssetIdViewModel(assetId: asset.id).assetImage }
    var suggestedAmounts: [Int] { Constants.suggestedAmounts }

    var cryptoAmountValue: String {
        guard let selectedQuoteViewModel else { return " " }
        return "≈ \(selectedQuoteViewModel.amountText)"
    }

    var showFiatTypePicker: Bool {
        assetData.balance.available > 0 && assetData.metadata.isSellEnabled
    }

    var assetBalance: String? {
        let text = balanceModel.availableBalanceText
        return text == .zero ? nil : text
    }

    var fiatProviderViewModel: FiatProvidersViewModel {
        FiatProvidersViewModel(state: quotesState.map { items in
            .plain(items.map { FiatQuoteViewModel(asset: asset, quote: $0, selectedQuote: selectedQuote, formatter: currencyFormatter) })
        })
    }

    var rateValue: String {
        guard let selectedQuoteViewModel else { return "" }
        return "1 \(asset.symbol) ≈ \(selectedQuoteViewModel.rateText)"
    }

    func buttonTitle(amount: Int) -> String {
        "\(currencyFormatter.symbol)\(amount)"
    }

    func providerAssetImage(_ provider: FiatProvider) -> AssetImage? {
        .resourceImage(image: provider.name.lowercased().replacing(" ", with: "_"))
    }
}

// MARK: - Business Logic

extension FiatSceneViewModel {
    func fetch() {
        quotesState = .data([])
        context.fetchTask?.cancel()

        context.fetchTask = Task {
            guard inputValidationModel.isValid, let amount = Double(inputValidationModel.text) else { return }
            quotesState = .loading
            selectedQuote = nil

            do {
                let quotes = try await strategy.fetch(amount: amount)

                try Task.checkCancellation()

                if quotes.isNotEmpty {
                    selectedQuote = quotes.first
                    quotesState = .data(quotes)
                    updateValidators()
                } else {
                    quotesState = .noData
                }
            } catch {
                guard !Task.isCancelled else { return }

                if !error.isCancelled {
                    quotesState = .error(error)
                    debugLog("FiatSceneViewModel get quotes error: \(error)")
                }
            }
        }
    }

    func onSelectContinue() {
        guard let selectedQuote else { return }

        Task {
            urlState = .loading

            do {
                let deviceId = try securePreferences.getDeviceId()
                let request = FiatQuoteUrlRequest(
                    quoteId: selectedQuote.id,
                    walletAddress: assetAddress.address,
                    deviceId: deviceId
                )

                guard let url = try await fiatService.getQuoteUrl(request: request).redirectUrl.asURL else {
                    urlState = .noData
                    return
                }

                urlState = .data(())
                await UIApplication.shared.open(url, options: [:])
            } catch {
                urlState = .noData
                quotesState = .error(error)
                debugLog("FiatSceneViewModel get quote URL error: \(error)")
            }
        }
    }

    func onSelect(amount: Int) {
        guard inputValidationModel.text != String(amount) else { return }
        reset()
        inputValidationModel.update(text: String(amount))
    }

    func onSelectRandomAmount() {
        reset()
        let amount = Int.random(in: Constants.defaultAmount..<Constants.randomMaxAmount) // mobsf-ignore: ios_insecure_random_no_generator (UI suggestion only)
        inputValidationModel.update(text: String(amount))
    }

    func onSelectFiatProviders() {
        isPresentingFiatProvider = true
    }

    func onSelectQuotes(_ quotes: [FiatQuoteViewModel]) {
        guard let quoteModel = quotes.first else { return }
        selectedQuote = quoteModel.quote
        isPresentingFiatProvider = false
    }

    func onChangeType(_: FiatQuoteType, type: FiatQuoteType) {
        inputValidationModel.text = context.amount
        updateValidators()
        fetch()
    }

    func onChangeAmountText(_: String, text: String) {
        context.amount = text
        selectedQuote = nil
        switch type {
        case .buy: break
        case .sell: updateValidators()
        }
    }
}

// MARK: - Private

extension FiatSceneViewModel {
    private var emptyAmountTitle: String {
        switch type {
        case .buy: Localized.Input.enterAmountTo(Localized.Wallet.buy)
        case .sell: Localized.Input.enterAmountTo(Localized.Wallet.sell)
        }
    }

    private var selectedQuoteViewModel: FiatQuoteViewModel? {
        guard let selectedQuote else { return nil }
        return FiatQuoteViewModel(asset: asset, quote: selectedQuote, selectedQuote: nil, formatter: currencyFormatter)
    }

    private var balanceModel: BalanceViewModel {
        BalanceViewModel(asset: asset, balance: assetData.balance, formatter: valueFormatter)
    }

    private func reset() {
        selectedQuote = nil
        updateValidators()
    }

    private func updateValidators() {
        inputValidationModel.update(
            validators: strategy.validators(
                availableBalance: assetData.balance.available,
                selectedQuote: selectedQuote
            )
        )
    }
}
