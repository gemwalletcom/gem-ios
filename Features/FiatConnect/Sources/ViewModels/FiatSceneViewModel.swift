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

@MainActor
@Observable
public final class FiatSceneViewModel {
    private let fiatService: any GemAPIFiatService
    private let assetAddress: AssetAddress
    private let walletId: String

    private let currencyFormatter = CurrencyFormatter(type: .currency, currencyCode: Preferences.standard.currency)
    private let valueFormatter = ValueFormatter(locale: .US, style: .medium)

    var input: FiatInput
    var state: StateViewType<[FiatQuote]> = .loading

    public init(
        fiatService: any GemAPIFiatService = GemAPIService(),
        assetAddress: AssetAddress,
        walletId: String,
        type: FiatTransactionType
    ) {
        self.fiatService = fiatService
        self.assetAddress = assetAddress
        self.walletId = walletId
        self.input = FiatInput(
            type: type,
            amount: FiatTransactionTypeViewModel(type: type).defaultAmount
        )
    }

    var title: String {
        switch input.type {
        case .buy: Localized.Buy.title(asset.name)
        case .sell: Localized.Sell.title(asset.name)
        }
    }

    var currencyInputConfig: any CurrencyInputConfigurable {
        FiatCurrencyInputConfig(
            type: input.type,
            assetAddress: assetAddress,
            secondaryText: secondaryTitle
        )
    }

    var actionButtonTitle: String { Localized.Common.continue }
    var providerTitle: String { Localized.Common.provider }
    var rateTitle: String { Localized.Buy.rate }
    var errorTitle: String { Localized.Errors.errorOccured }
    var availableTitle: String { Localized.Asset.Balances.available }
    var emptyTitle: String { input.amount.isZero ? emptyAmountTitle : emptyQuotesTitle}
    var assetTitle: String { asset.symbol }

    var typeAmountButtonTitle: String {
        switch input.type {
        case .buy: Emoji.random
        case .sell: Localized.Transfer.max
        }
    }

    var typeAmountButtonStyle: ColorButtonStyle {
        switch input.type {
        case .buy: .amount()
        case .sell: .lightGray(paddingHorizontal: Spacing.small, paddingVertical: Spacing.small)
        }
    }

    var assetRequest: AssetRequest {
        AssetRequest(walletId: walletId, assetId: assetAddress.asset.id.identifier)
    }

    var asset: Asset { assetAddress.asset }
    var assetImage: AssetImage { AssetIdViewModel(assetId: asset.id).assetImage }

    func assetBalance(assetData: AssetData) -> String {
        balanceModel(assetData: assetData).availableBalanceText
    }

    var suggestedAmounts: [Double] { typeModel.suggestedAmounts }

    var cryptoAmountValue: String {
        guard let quote = input.quote else { return "" }
        let quoteAmount = FiatQuoteViewModel(asset: asset, quote: quote, formatter: currencyFormatter).amountText
        return "≈ \(quoteAmount)"
    }

    func rateValue(for quote: FiatQuote) -> String {
        let quoteRate = FiatQuoteViewModel(asset: asset, quote: quote, formatter: currencyFormatter).rateText
        return "1 \(asset.symbol) ≈ \(quoteRate)"
    }

    func buttonTitle(amount: Double) -> String {
        switch input.type {
        case .buy: "\(currencyInputConfig.currencySymbol)\(Int(amount))"
        case .sell: "\(Int(amount))%"
        }
    }

    var amountText: String {
        get {
            formattedAmount
        }
        set {
            input.amount = amount(text: newValue)
        }
    }
}

// MARK: - Private

extension FiatSceneViewModel {
    private var emptyQuotesTitle: String { Localized.Buy.noResults }
    private var emptyAmountTitle: String {
        switch input.type {
        case .buy: Localized.Input.enterAmountTo(Localized.Input.buy)
        case .sell: Localized.Input.enterAmountTo(Localized.Input.sell)
        }
    }
    private var secondaryTitle: String {
        if amountText.isEmpty {
            emptyAmountTitle
        } else {
            cryptoAmountValue
        }
    }

    private func balanceModel(assetData: AssetData) -> BalanceViewModel {
        BalanceViewModel(asset: asset, balance: assetData.balance, formatter: valueFormatter)
    }

    private var typeModel: FiatTransactionTypeViewModel {
        FiatTransactionTypeViewModel(type: input.type)
    }

    private var formattedAmount: String {
        switch input.type {
        case .buy:
            return String(format: "%.0f", input.amount)
        case .sell:
            guard let bigIntNumber = try? valueFormatter.inputNumber(from: String(input.amount), decimals: asset.decimals.asInt) else {
                return String(input.amount)
            }
            return valueFormatter.string(bigIntNumber, decimals: asset.decimals.asInt)
        }
    }

    private func amount(text: String) -> Double {
        guard let bigIntNumber = try? valueFormatter.inputNumber(from: text, decimals: asset.decimals.asInt),
              let doubleNumber = (try? valueFormatter.double(from: bigIntNumber, decimals: asset.decimals.asInt)) else {
            return Double(text) ?? .zero
        }
        return doubleNumber
    }

    private func maxAmount(assetData: AssetData) -> Double {
        switch input.type {
        case .buy: FiatTransactionTypeViewModel.defaultBuyMaxAmount
        case .sell: balanceModel(assetData: assetData).availableBalanceAmount
        }
    }

    private func shouldProceedFetch(assetData: AssetData) -> Bool {
        guard !input.amount.isZero else { return false }
        switch input.type {
        case .buy: return true
        case .sell: return input.amount <= maxAmount(assetData: assetData)
        }
    }
}

// MARK: - Business Logic

extension FiatSceneViewModel {
    func onSelectQuote(_ quote: FiatQuote) {
        input.quote = quote
    }

    func select(amount: Double, assetData: AssetData) {
        switch input.type {
        case .buy:
            input.amount = amount
        case .sell:
            input.amount = maxAmount(assetData: assetData) * (amount / 100)
        }
    }

    func selectTypeAmount(assetData: AssetData) {
        let maxAmount = maxAmount(assetData: assetData)
        switch input.type {
        case .buy:
            input.amount = typeModel.randomAmount(maxAmount: maxAmount) ?? .zero
        case .sell:
            input.amount = maxAmount
        }
    }

    func fetch(for assetData: AssetData) async {
        let shouldFetch: Bool = await MainActor.run { [self] in
            self.input.quote = nil
            if !self.shouldProceedFetch(assetData: assetData) {
                self.state = .noData
                return false
            }
            self.state = .loading
            return true
        }

        guard shouldFetch else { return }

        do {
            let quotes: [FiatQuote] = try await {
                let request = FiatBuyRequest(
                    assetId: asset.id.identifier,
                    fiatCurrency: Currency.usd.rawValue,
                    fiatAmount: input.amount,
                    walletAddress: assetAddress.address
                )
                switch input.type {
                case .buy:
                    return try await fiatService.getBuyQuotes(asset: asset, request: request)
                case .sell:
                    return try await fiatService.getSellQuotes(asset: asset, request: request)
                }
            }()
            await MainActor.run { [self] in
                if !quotes.isEmpty {
                    self.input.quote = quotes.first
                    self.state = .loaded(quotes)
                } else {
                    self.state = .noData
                }
            }
        } catch {
            await MainActor.run { [self] in
                if !error.isCancelled {
                    self.state = .error(error)
                    NSLog("get quotes error: \(error)")
                }
            }
        }
    }
}
