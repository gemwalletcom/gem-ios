// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI
import GemAPI
import Components
import Localization
import PrimitivesComponents
import Formatters
import Validators
import BigInt

@MainActor
@Observable
final class FiatOperationViewModel {
    private let operation: FiatOperation
    private let asset: Asset
    private let currencyFormatter: CurrencyFormatter

    var quotesState: StateViewType<FiatQuotes> = .loading
    var selectedQuote: FiatQuote?
    var fetchTask: Task<Void, Never>?
    var amount: String
    var loadingAmount: Double?
    var inputValidationModel: InputValidationViewModel
    var availableBalance: BigInt = 0

    init(
        operation: FiatOperation,
        asset: Asset,
        currencyFormatter: CurrencyFormatter
    ) {
        self.operation = operation
        self.asset = asset
        self.currencyFormatter = currencyFormatter
        self.amount = String(operation.defaultAmount)
        self.inputValidationModel = InputValidationViewModel(
            mode: .onDemand,
            validators: []
        )
        self.inputValidationModel.text = amount
        updateValidators()
    }

    var cryptoAmountValue: String {
        guard let selectedQuoteViewModel else { return " " }
        return "≈ \(selectedQuoteViewModel.amountText)"
    }

    var rateValue: String {
        guard let selectedQuoteViewModel else { return "" }
        return "1 \(asset.symbol) ≈ \(selectedQuoteViewModel.rateText)"
    }

    var emptyTitle: String {
        inputValidationModel.text.isEmptyOrZero ? operation.emptyAmountTitle : Localized.Buy.noResults
    }

    func fetch() {
        guard let amount = Double(inputValidationModel.text), amount > 0 else {
            quotesState = .noData
            return
        }

        if inputValidationModel.isInvalid {
            return
        }

        if shouldSkipFetch(for: amount) {
            return
        }

        fetchTask?.cancel()
        loadingAmount = amount

        fetchTask = Task {
            setLoadingState()
            selectedQuote = nil

            do {
                let quotes = try await operation.fetch(amount: amount)
                try Task.checkCancellation()

                let fiatQuotes = FiatQuotes(amount: amount, quotes: quotes)

                if quotes.isNotEmpty {
                    selectedQuote = quotes.first
                    quotesState = .data(fiatQuotes)
                    updateValidators()
                } else {
                    quotesState = .noData
                }
            } catch {
                guard !Task.isCancelled else { return }

                if !error.isCancelled {
                    quotesState = .error(error)
                    debugLog("FiatOperationViewModel get quotes error: \(error)")
                }
            }

            loadingAmount = nil
        }
    }

    func shouldSkipFetch(for amount: Double) -> Bool {
        if loadingAmount == amount {
            return true
        }

        switch quotesState {
        case .data(let fiatQuotes):
            return fiatQuotes.amount == amount
        case .loading, .noData, .error:
            return false
        }
    }

    func reset() {
        selectedQuote = nil
        updateValidators()
    }

    func updateValidators() {
        inputValidationModel.update(
            validators: operation.validators(
                availableBalance: availableBalance,
                selectedQuote: selectedQuote
            )
        )
    }

    func onChangeAmountText(_: String, text: String) {
        if text != amount {
            selectedQuote = nil
            setLoadingState()
        }
        amount = text
        updateValidators()
    }

    private func setLoadingState() {
        guard !quotesState.isLoading else { return }
        quotesState = .loading
    }
}

extension FiatOperationViewModel {

    private var selectedQuoteViewModel: FiatQuoteViewModel? {
        guard let selectedQuote else { return nil }
        return FiatQuoteViewModel(asset: asset, quote: selectedQuote, selectedQuote: nil, formatter: currencyFormatter)
    }
}
