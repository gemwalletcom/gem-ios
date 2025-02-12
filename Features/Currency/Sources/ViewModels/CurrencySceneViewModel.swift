// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components
import Localization

@Observable
public final class CurrencySceneViewModel {
    private var currencyStorage: CurrencyStorable

    var currency: Currency {
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

    public init(currencyStorage: CurrencyStorable) {
        self.currencyStorage = currencyStorage
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
}

// MARK: - Private

extension CurrencySceneViewModel {
    private var defaultCurrencies: [Currency] {
        let defaultCurrencies: [Currency] = [.usd, .eur, .gbp, .cny, .jpy, .inr, .rub]
        return defaultCurrencies + [currency]
    }

    private var recommendedCurrencies: [Currency] {
        guard let current = Locale.current.currency,
              let currency = Currency(rawValue: current.identifier)
        else {
            return defaultCurrencies
        }
        return ([currency] + defaultCurrencies).unique()
    }

    private var allCurrencies: [Currency] {
        Currency.nativeCurrencies.compactMap({ Currency(rawValue: $0.identifier) })
    }
}
