// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store
import Preferences
import Formatters
import Localization
import PrimitivesComponents

@MainActor
@Observable
public final class AssetPriceDetailsViewModel {
    var priceData: PriceData?
    var priceRequest: PriceRequest

    private let currencyFormatter: CurrencyFormatter

    public init(
        assetId: AssetId,
        preferences: Preferences = .standard
    ) {
        self.priceRequest = PriceRequest(assetId: assetId)
        self.currencyFormatter = CurrencyFormatter(type: .abbreviated, currencyCode: preferences.currency)
    }

    var title: String { Localized.Markets.title }

    var marketValues: [MarketValueViewModel] {
        [
            MarketValueViewModel(title: Localized.Asset.marketCap, subtitle: marketCapText),
            MarketValueViewModel(title: Localized.Asset.tradingVolume, subtitle: tradingVolumeText),
            MarketValueViewModel(title: "Fully Diluted Valuation", subtitle: marketCapFdvText),

            MarketValueViewModel(title: Localized.Asset.circulatingSupply, subtitle: circulatingSupplyText),
            MarketValueViewModel(title: Localized.Asset.totalSupply, subtitle: totalSupplyText),
            MarketValueViewModel(title: "Max Supply", subtitle: maxSupplyText),

            MarketValueViewModel(title: "All Time High", subtitle: allTimeHighText, subtitleExtra: allTimeHighDateText),
            MarketValueViewModel(title: "All Time Low", subtitle: allTimeLowText, subtitleExtra: allTimeLowDateText),
        ].filter { $0.subtitle?.isEmpty == false }
    }

    private var marketCapText: String? {
        guard let value = priceData?.market?.marketCap else { return nil }
        return currencyFormatter.string(value)
    }

    private var marketCapFdvText: String? {
        guard let value = priceData?.market?.marketCapFdv else { return nil }
        return currencyFormatter.string(value)
    }

    private var tradingVolumeText: String? {
        guard let value = priceData?.market?.totalVolume else { return nil }
        return currencyFormatter.string(value)
    }

    private var circulatingSupplyText: String? {
        guard let value = priceData?.market?.circulatingSupply else { return nil }
        return currencyFormatter.string(double: value)
    }

    private var totalSupplyText: String? {
        guard let value = priceData?.market?.totalSupply else { return nil }
        return currencyFormatter.string(double: value)
    }

    private var maxSupplyText: String? {
        guard let value = priceData?.market?.maxSupply else { return nil }
        return currencyFormatter.string(double: value)
    }

    private var allTimeHighText: String? {
        guard let value = priceData?.market?.allTimeHigh else { return nil }
        return CurrencyFormatter(currencyCode: Preferences.standard.currency).string(value)
    }

    private var allTimeHighDateText: String? {
        guard let date = priceData?.market?.allTimeHighDate else { return nil }
        return TransactionDateFormatter(date: date).section
    }

    private var allTimeLowText: String? {
        guard let value = priceData?.market?.allTimeLow else { return nil }
        return CurrencyFormatter(currencyCode: Preferences.standard.currency).string(value)
    }

    private var allTimeLowDateText: String? {
        guard let date = priceData?.market?.allTimeLowDate else { return nil }
        return TransactionDateFormatter(date: date).section
    }
}
