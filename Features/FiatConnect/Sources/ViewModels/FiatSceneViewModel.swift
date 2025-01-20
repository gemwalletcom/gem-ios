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

    private let valueFormatter = ValueFormatter(locale: .US, style: .medium)

    let currencyFormatter: CurrencyFormatter

    var amountText: String
    var input: FiatInput
    var state: StateViewType<[FiatQuote]> = .loading

    public init(
        fiatService: any GemAPIFiatService = GemAPIService(),
        currencyFormatter: CurrencyFormatter = CurrencyFormatter(currencyCode: Currency.usd.rawValue),
        assetAddress: AssetAddress,
        walletId: String
    ) {
        self.fiatService = fiatService
        self.currencyFormatter = currencyFormatter
        self.assetAddress = assetAddress
        self.walletId = walletId

        let input = FiatInput(type: .buy)
        let defaultAmount = FiatTransactionTypeViewModel(type: input.type).defaultAmount
        self.input = input
        self.amountText = String(Int(defaultAmount))
    }

    var title: String {
        switch input.type {
        case .buy: Localized.Buy.title(asset.name)
        case .sell: Localized.Sell.title(asset.name)
        }
    }

    func pickerTitle(type: FiatTransactionType) -> String {
        typeModel(type: type).title
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
        case .sell: .lightGray(paddingHorizontal: Spacing.small, paddingVertical: Spacing.small)
        }
    }

    var assetRequest: AssetRequest {
        AssetRequest(walletId: walletId, assetId: assetAddress.asset.id.identifier)
    }

    var asset: Asset { assetAddress.asset }
    var assetImage: AssetImage { AssetIdViewModel(assetId: asset.id).assetImage }

    var suggestedAmounts: [Double] { typeModel(type: input.type).suggestedAmounts }

    var cryptoAmountValue: String {
        guard let quote = input.quote else { return "" }
        let quoteAmount = FiatQuoteViewModel(asset: asset, quote: quote, formatter: currencyFormatter).amountText
        return "≈ \(quoteAmount)"
    }
    
    func showFiatTypePicker(_ assetData: AssetData) -> Bool {
        assetData.balance.available > 0 && assetData.metadata.isSellEnabled
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

    func assetBalance(assetData: AssetData) -> String {
        balanceModel(assetData: assetData).availableBalanceText
    }
}

// MARK: - Private

extension FiatSceneViewModel {
    private var emptyQuotesTitle: String { Localized.Buy.noResults }
    private var emptyAmountTitle: String {
        switch input.type {
        case .buy: Localized.Input.enterAmountTo(Localized.Wallet.buy)
        case .sell: Localized.Input.enterAmountTo(Localized.Wallet.sell)
        }
    }

    private func balanceModel(assetData: AssetData) -> BalanceViewModel {
        BalanceViewModel(asset: asset, balance: assetData.balance, formatter: valueFormatter)
    }

    private func typeModel(type: FiatTransactionType) -> FiatTransactionTypeViewModel {
        FiatTransactionTypeViewModel(type: type)
    }

    private func parseAmount(text: String) -> Double {
        switch input.type {
        case .buy:
            return Double(text) ?? .zero
        case .sell:
            guard let bigIntNumber = try? valueFormatter.inputNumber(from: text, decimals: asset.decimals.asInt),
                  let doubleNumber = (try? valueFormatter.double(from: bigIntNumber, decimals: asset.decimals.asInt))
            else {
                return Double(text) ?? .zero
            }
            return doubleNumber
        }
    }

    private func formatAmount(_ amount: Double) -> String {
        switch input.type {
        case .buy:
            return String(Int(amount))
        case .sell:
            guard let bigIntNumber = try? valueFormatter.inputNumber(from: String(amount), decimals: asset.decimals.asInt),
                  !bigIntNumber.isZero
            else {
                return ""
            }
            return valueFormatter.string(bigIntNumber, decimals: asset.decimals.asInt)
        }
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
    func selectQuote(_ quote: FiatQuote) {
        input.quote = quote
    }

    func selectType(_ type: FiatTransactionType) {
        input.type = type
        amountText = formatAmount(input.amount)
    }

    func select(amount: Double, assetData: AssetData) {
        switch input.type {
        case .buy:
            amountText = formatAmount(amount)
        case .sell:
            let percentAmount = maxAmount(assetData: assetData) * (amount / 100)
            amountText = formatAmount(percentAmount)
        }
    }

    func selectTypeAmount(assetData: AssetData) {
        let maxAmount = maxAmount(assetData: assetData)
        switch input.type {
        case .buy:
            let randomAmount = typeModel(type: input.type).randomAmount(maxAmount: maxAmount) ?? .zero
            amountText = formatAmount(randomAmount)
        case .sell:
            amountText = formatAmount(maxAmount)
        }
    }

    func changeAmountText(_: String, text: String) {
        input.amount = parseAmount(text: text)
    }

    func fetch(for assetData: AssetData) async {
        input.quote = nil

        guard shouldProceedFetch(assetData: assetData) else {
            state = .noData
            return
        }
        state = .loading

        do {
            let quotes: [FiatQuote] = try await {
                let request = FiatBuyRequest(
                    assetId: asset.id.identifier,
                    fiatCurrency: currencyFormatter.currencyCode,
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

            if !quotes.isEmpty {
                input.quote = quotes.first
                state = .loaded(quotes)
            } else {
                state = .noData
            }
        } catch {
            if !error.isCancelled {
                state = .error(error)
                NSLog("get quotes error: \(error)")
            }
        }
    }
}
