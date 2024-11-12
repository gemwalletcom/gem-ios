// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI
import GemAPI
import Components
import Style
import Localization
import FiatConnect
import Store

@Observable
class FiatViewModel {
    static let quoteTaskDebounceTimeout = Duration.milliseconds(300)

    private let fiatService: any GemAPIFiatService
    private let assetAddress: AssetAddress
    private let walletId: String

    private let currencyFormatter = CurrencyFormatter.currency()
    private let valueFormatter = ValueFormatter(style: .medium)

    var input: FiatInput
    var state: StateViewType<[FiatQuote]> = .loading

    init(
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
        let name = asset.name
        return isBuy ? Localized.Buy.title(name) : Localized.Sell.title(name)
    }

    var keyboardType: UIKeyboardType { isBuy ? .numberPad : .decimalPad }
    var currencyPosition: CurrencyTextField.CurrencyPosition { isBuy ? .leading : .trailing }

    var actionButtonTitle: String { Localized.Common.continue }
    var providerTitle: String { Localized.Common.provider }
    var rateTitle: String { Localized.Buy.rate }
    var errorTitle: String { Localized.Errors.errorOccured }
    var emptyTitle: String { input.amount.isZero ? emptyAmountTitle : emptyQuotesTitle}
    var typeAmountButtonTitle: String { isBuy ? Emoji.random : Localized.Transfer.max }
    var assetTitle: String { asset.symbol }
    var availableTitle: String { Localized.Asset.Balances.available }

    var isBuy: Bool { input.type == .buy }

    var assetRequest: AssetRequest {
        AssetRequest(walletId: walletId, assetId: assetAddress.asset.id.identifier)
    }

    var asset: Asset { assetAddress.asset }
    var assetImage: AssetImage { AssetIdViewModel(assetId: asset.id).assetImage }

    func assetBalance(assetData: AssetData) -> String? {
        guard !isBuy else { return .none }
        return balanceModel(assetData: assetData).availableBalanceTextWithSymbol
    }

    var suggestedAmounts: [Double] { typeModel.suggestedAmounts }
    var currencySymbol: String { isBuy ? "$" : assetAddress.asset.symbol }

    var cryptoAmountValue: String {
        guard let quote = input.quote else { return "" }
        let quoteAmount = FiatQuoteViewModel(asset: asset,quote: quote,formatter: currencyFormatter).amount
        return "≈ \(quoteAmount)"
    }

    func rateValue(for quote: FiatQuote) -> String {
        let quoteRate = FiatQuoteViewModel(asset: asset, quote: quote, formatter: currencyFormatter).rateText
        return "1 \(asset.symbol) ≈ \(quoteRate)"
    }

    func buttonTitle(amount: Double) -> String {
        isBuy ? "\(currencySymbol)\(Int(amount))" : "\(Int(amount))%"
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

extension FiatViewModel {
    private var emptyQuotesTitle: String { Localized.Buy.noResults }
    private var emptyAmountTitle: String { Localized.Buy.emptyAmount }

    private var address: String { assetAddress.address }

    private func balanceModel(assetData: AssetData) -> BalanceViewModel {
        BalanceViewModel(asset: asset, balance: assetData.balance, formatter: valueFormatter)
    }

    private func availableBalance(assetData: AssetData) -> Double {
        balanceModel(assetData: assetData).availableBalanceAmount
    }

    private var typeModel: FiatTransactionTypeViewModel {
        FiatTransactionTypeViewModel(type: input.type)
    }

    private var formattedAmount: String {
        guard !isBuy else {
            return String(format: "%.0f", input.amount)
        }
        let value = String(input.amount).replacingOccurrences(of: ".", with: ",")
        guard let bigIntNumber = try? valueFormatter.inputNumber(from: value, decimals: asset.decimals.asInt) else { return String(input.amount) }
        return valueFormatter.string(bigIntNumber, decimals: asset.decimals.asInt)
    }

    private func amount(text: String) -> Double {
        guard let bigIntNumber = try? valueFormatter.inputNumber(from: text, decimals: asset.decimals.asInt),
              let doubleNumber = (try? valueFormatter.double(from: bigIntNumber, decimals: asset.decimals.asInt)) else {
            return Double(text) ?? .zero
        }
        return doubleNumber
    }

    private func maxAmount(assetData: AssetData) -> Double {
        isBuy ? FiatTransactionTypeViewModel.defaultBuyMaxAmount : availableBalance(assetData: assetData)
    }

    private func shouldProceedFetch(assetData: AssetData) -> Bool {
        guard !input.amount.isZero else { return false }
        return isBuy || (!isBuy && input.amount <= maxAmount(assetData: assetData))
    }
}

// MARK: - Business Logic

extension FiatViewModel {
    func select(amount: Double, assetData: AssetData) {
        if isBuy {
            input.amount = amount
        } else {
            input.amount = availableBalance(assetData: assetData) * (amount / 100)
        }
    }

    func selectTypeAmount(assetData: AssetData) {
        let maxAmount = maxAmount(assetData: assetData)
        if isBuy {
            input.amount = typeModel.randomAmount(maxAmount: maxAmount) ?? .zero
        } else {
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
            let quotes = try await fiatService.getQuotes(
                asset: asset,
                buy: isBuy,
                request: FiatBuyRequest(
                    assetId: asset.id.identifier,
                    fiatCurrency: Currency.usd.rawValue,
                    fiatAmount: input.amount,
                    walletAddress: address
                )
            )
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
