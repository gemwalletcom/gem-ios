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

    var assetData: AssetData = .empty {
        didSet {
            buyViewModel.availableBalance = assetData.balance.available
            sellViewModel.availableBalance = assetData.balance.available
        }
    }
    var assetRequest: AssetRequest
    var urlState: StateViewType<Void> = .noData
    var type: FiatQuoteType
    var isPresentingFiatProvider: Bool = false
    var isPresentingAlertMessage: AlertMessage?

    let buyViewModel: FiatOperationViewModel
    let sellViewModel: FiatOperationViewModel

    public init(
        fiatService: any GemAPIFiatService = GemAPIService(),
        securePreferences: SecurePreferences = SecurePreferences(),
        currencyFormatter: CurrencyFormatter = CurrencyFormatter(currencyCode: Currency.usd.rawValue),
        assetAddress: AssetAddress,
        walletId: WalletId,
        type: FiatQuoteType = .buy,
        amount: Int? = nil
    ) {
        self.fiatService = fiatService
        self.securePreferences = securePreferences
        self.currencyFormatter = currencyFormatter
        self.assetAddress = assetAddress
        self.type = type
        self.assetRequest = AssetRequest(walletId: walletId, assetId: assetAddress.asset.id)

        let buyOperation = BuyOperation(
            service: fiatService,
            asset: assetAddress.asset,
            currencyFormatter: currencyFormatter
        )
        let sellOperation = SellOperation(
            service: fiatService,
            asset: assetAddress.asset,
            currencyFormatter: currencyFormatter
        )

        self.buyViewModel = FiatOperationViewModel(
            operation: buyOperation,
            asset: assetAddress.asset,
            currencyFormatter: currencyFormatter
        )
        self.sellViewModel = FiatOperationViewModel(
            operation: sellOperation,
            asset: assetAddress.asset,
            currencyFormatter: currencyFormatter
        )

        if let amount {
            currentViewModel.inputValidationModel.text = String(amount)
        }
    }

    var currentViewModel: FiatOperationViewModel {
        switch type {
        case .buy: buyViewModel
        case .sell: sellViewModel
        }
    }

    var quotesState: StateViewType<[FiatQuote]> {
        currentViewModel.quotesState.map { $0.quotes }
    }

    var selectedQuote: FiatQuote? {
        currentViewModel.selectedQuote
    }

    var inputValidationModel: InputValidationViewModel {
        get { currentViewModel.inputValidationModel }
        set { currentViewModel.inputValidationModel = newValue }
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
        FiatCurrencyInputConfig(secondaryText: currentViewModel.cryptoAmountValue, currencySymbol: currencyFormatter.symbol)
    }

    var actionButtonTitle: String { Localized.Common.continue }
    var actionButtonState: StateViewType<[FiatQuote]> {
        if selectedQuote == nil { return .noData }
        if urlState.isLoading { return .loading }
        if currentViewModel.inputValidationModel.isInvalid || currentViewModel.inputValidationModel.text.isEmptyOrZero { return .noData }
        return quotesState
    }
    var providerTitle: String { Localized.Common.provider }
    var rateTitle: String { Localized.Buy.rate }
    var errorTitle: String { Localized.Errors.errorOccured }
    var emptyTitle: String { currentViewModel.emptyTitle }
    var assetTitle: String { asset.name }
    var typeAmountButtonTitle: String { Emoji.random }
    var asset: Asset { assetAddress.asset }
    var assetImage: AssetImage { AssetIdViewModel(assetId: asset.id).assetImage }
    var suggestedAmounts: [Int] { Constants.suggestedAmounts }

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
        currentViewModel.rateValue
    }

    func buttonTitle(amount: Int) -> String {
        "\(currencyFormatter.symbol)\(amount)"
    }

    func providerAssetImage(_ provider: FiatProvider) -> AssetImage? {
        .resourceImage(image: provider.name.lowercased().replacing(" ", with: "_"))
    }
}

// MARK: - Actions

extension FiatSceneViewModel {
    func fetch() {
        currentViewModel.fetch()
    }

    func onSelectContinue() {
        guard let selectedQuote = currentViewModel.selectedQuote else { return }

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
                urlState = .error(error)
                isPresentingAlertMessage = AlertMessage(
                    title: Localized.Errors.errorOccured,
                    message: error.localizedDescription
                )
                debugLog("FiatSceneViewModel get quote URL error: \(error)")
            }
        }
    }

    func onSelect(amount: Int) {
        guard currentViewModel.inputValidationModel.text != String(amount) else { return }
        selectAmount(amount)
    }

    func onSelectRandomAmount() {
        let amount = Int.random(in: Constants.defaultAmount..<Constants.randomMaxAmount)
        selectAmount(amount)
    }

    func onSelectFiatProviders() {
        isPresentingFiatProvider = true
    }

    func onSelectQuotes(_ quotes: [FiatQuoteViewModel]) {
        guard let quoteModel = quotes.first else { return }
        currentViewModel.selectedQuote = quoteModel.quote
        isPresentingFiatProvider = false
    }

    func onChangeType(_: FiatQuoteType, type: FiatQuoteType) {
        currentViewModel.inputValidationModel.text = currentViewModel.amount
        currentViewModel.updateValidators()
        currentViewModel.fetch()
    }

    func onChangeAmountText(_: String, text: String) {
        currentViewModel.onChangeAmountText("", text: text)
    }
}

// MARK: - Private

extension FiatSceneViewModel {
    private var balanceModel: BalanceViewModel {
        BalanceViewModel(asset: asset, balance: assetData.balance, formatter: valueFormatter)
    }

    private func selectAmount(_ amount: Int) {
        currentViewModel.reset()
        currentViewModel.inputValidationModel.update(text: String(amount))
        currentViewModel.fetch()
    }
}
