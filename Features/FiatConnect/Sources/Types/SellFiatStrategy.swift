// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemAPI
import Validators
import BigInt
import Formatters
import Localization

struct SellFiatStrategy: FiatOperationStrategy {
    private struct Constants {
        static let minimumFiatAmount: Int = 25
        static let maximumFiatAmount: Int = 10000
    }

    let type: FiatQuoteType = .sell
    private let service: any GemAPIFiatService
    private let asset: Asset
    private let currencyFormatter: CurrencyFormatter

    init(
        service: any GemAPIFiatService,
        asset: Asset,
        currencyFormatter: CurrencyFormatter
    ) {
        self.service = service
        self.asset = asset
        self.currencyFormatter = currencyFormatter
    }

    func fetch(amount: Double) async throws -> [FiatQuote] {
        let request = FiatQuoteRequest(amount: amount, currency: currencyFormatter.currencyCode)
        return try await service.getQuotes(type: .sell, assetId: asset.id, request: request)
    }

    func validators(
        availableBalance: BigInt,
        selectedQuote: FiatQuote?
    ) -> [any TextValidator] {
        let rangeValidator = FiatRangeValidator(
            range: BigInt(Constants.minimumFiatAmount)...BigInt(Constants.maximumFiatAmount),
            minimumValueText: currencyFormatter.string(Double(Constants.minimumFiatAmount)),
            maximumValueText: currencyFormatter.string(Double(Constants.maximumFiatAmount))
        )
        let sellValidator = FiatSellValidator(
            quote: selectedQuote,
            availableBalance: availableBalance,
            asset: asset
        )
        return [.assetAmount(decimals: 0, validators: [rangeValidator, sellValidator])]
    }
}
