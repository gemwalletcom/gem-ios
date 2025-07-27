// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components
import Localization
import PriceService

@Observable
public final class CurrencySceneViewModel {
    private var currencyStorage: CurrencyStorable
    private let priceService: PriceService
    private let defaultCurrencies: [Currency] = [.usd, .eur, .gbp, .cny, .jpy, .inr, .rub]
    
    private(set) var currency: Currency {
        get {
            guard let currency = Currency(rawValue: currencyStorage.currency) else {
                fatalError("unsupported currency")
            }
            return currency
        }
        set {
            currencyStorage.currency = newValue.rawValue
        }
    }

    public init(
        currencyStorage: CurrencyStorable,
        priceService: PriceService
    ) {
        self.currencyStorage = currencyStorage
        self.priceService = priceService
    }

    public var selectedCurrencyValue: String {
        let model = CurrencyViewModel(currency: currency)
        if let flag = model.flag {
            return "\(flag) \(currency.rawValue)"
        }
        return currency.rawValue
    }

    var title: String { Localized.Settings.currency }

    var list: [ListItemValueSection<CurrencyViewModel>] {
        let recommendedVMs = recommendedCurrencies.map { CurrencyViewModel(currency: $0) }
        let recommendedValues = recommendedVMs.map { ListItemValue(title: $0.title, value: $0) }
        let allVMs = allCurrencies.map { CurrencyViewModel(currency: $0) }
        let allValues = allVMs.map { ListItemValue(title: $0.title, value: $0) }

        return [
            ListItemValueSection(
                section: Localized.Common.recommended,
                values: recommendedValues
            ),
            ListItemValueSection(
                section: Localized.Common.all,
                values: allValues
            )
        ]
    }
    
    func setCurrency(_ currency: Currency) throws {
        self.currency = currency
        try self.priceService.changeCurrency(currency: currency.rawValue)
    }
}

// MARK: - Private

extension CurrencySceneViewModel {

    private var recommendedCurrencies: [Currency] {
        guard let current = Locale.current.currency,
              let currency = Currency(rawValue: current.identifier)
        else {
            return defaultCurrencies
        }
        return ([self.currency, currency] + defaultCurrencies).unique()
    }

    private var allCurrencies: [Currency] {
        Currency.nativeCurrencies.compactMap({ Currency(rawValue: $0.identifier) })
    }
}
