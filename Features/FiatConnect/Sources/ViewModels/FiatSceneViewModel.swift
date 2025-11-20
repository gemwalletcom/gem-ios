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
        static let minimumFiatAmount: Int = 5
        static let maximumFiatAmount: Int = 10000
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

    var quotesState: StateViewType<[FiatQuote]> = .loading
    var urlState: StateViewType<Void> = .noData
    var type: FiatQuoteType
    var amount: Int = 0
    var selectedQuote: FiatQuote?
    var inputValidationModel: InputValidationViewModel = InputValidationViewModel()

    var isPresentingFiatProvider: Bool = false

    private var fetchTask: Task<Void, Never>?

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
        self.amount = Constants.defaultAmount
        self.assetRequest = AssetRequest(walletId: walletId, assetId: assetAddress.asset.id)

        self.inputValidationModel = InputValidationViewModel(
            mode: .onDemand,
            validators: inputValidation
        )
        self.inputValidationModel.text = String(Constants.defaultAmount)
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
        if urlState.isLoading { return .loading }
        if !inputValidationModel.isValid { return .noData }
        return quotesState
    }
    var providerTitle: String { Localized.Common.provider }
    var rateTitle: String { Localized.Buy.rate }
    var errorTitle: String { Localized.Errors.errorOccured }
    var emptyTitle: String { amount == 0 ? emptyAmountTitle : Localized.Buy.noResults}
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
        inputValidationModel.text = String(amount)
    }

    func onSelectRandomAmount() {
        let randomAmount = Int.random(in: Constants.defaultAmount..<Constants.randomMaxAmount) // mobsf-ignore: ios_insecure_random_no_generator (UI suggestion only)
        inputValidationModel.text = String(randomAmount)
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
        fetch()
    }

    func onChangeAmountValue(_ amount: Int) {
        fetch()
    }

    func onChangeAmountText(_: String, text: String) {
        amount = Int(text) ?? .zero
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

    private var inputValidation: [any TextValidator] {
        let validators: [any ValueValidator<BigInt>] = switch type {
        case .buy:
            [FiatRangeValidator(
                range: BigInt(Constants.minimumFiatAmount)...BigInt(Constants.maximumFiatAmount),
                minimumValueText: currencyFormatter.string(Double(Constants.minimumFiatAmount)),
                maximumValueText: currencyFormatter.string(Double(Constants.maximumFiatAmount))
            )]
        case .sell:
            [FiatSellValidator(
                quote: selectedQuote,
                availableBalance: assetData.balance.available,
                asset: asset
            )]
        }

        return [.assetAmount(decimals: 0, validators: validators)]
    }

    private func fetch() {
        fetchTask?.cancel()

        fetchTask = Task {
            selectedQuote = nil
            quotesState = .loading
            updateInputValidators()

            do {
                let request = FiatQuoteRequest(
                    amount: Double(amount),
                    currency: currencyFormatter.currencyCode
                )

                let quotes = try await fiatService.getQuotes(type: type, assetId: asset.id, request: request)

                try Task.checkCancellation()

                if !quotes.isEmpty {
                    selectedQuote = quotes.first
                    quotesState = .data(quotes)
                    updateInputValidators()
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

    private func updateInputValidators() {
        inputValidationModel.update(validators: inputValidation)
    }
}
