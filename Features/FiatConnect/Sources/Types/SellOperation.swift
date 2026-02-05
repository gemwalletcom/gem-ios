// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemAPI
import Validators
import BigInt
import Formatters
import Localization
import Preferences

struct SellOperation: FiatOperation {
    private let service: any GemAPIFiatService
    private let asset: Asset
    private let currencyFormatter: CurrencyFormatter
    private let securePreferences: SecurePreferences
    private let walletId: WalletId

    private let config = FiatOperationConfig(
        defaultAmount: 100,
        minimumAmount: 25,
        maximumAmount: 10000
    )

    var defaultAmount: Int { config.defaultAmount }

    var emptyAmountTitle: String {
        Localized.Input.enterAmountTo(Localized.Wallet.sell)
    }

    init(
        service: any GemAPIFiatService,
        asset: Asset,
        currencyFormatter: CurrencyFormatter,
        securePreferences: SecurePreferences,
        walletId: WalletId
    ) {
        self.service = service
        self.asset = asset
        self.currencyFormatter = currencyFormatter
        self.securePreferences = securePreferences
        self.walletId = walletId
    }

    func fetch(amount: Double) async throws -> [FiatQuote] {
        let deviceId = try securePreferences.getDeviceId()
        let request = FiatQuoteRequest(amount: amount, currency: currencyFormatter.currencyCode)
        return try await service.getQuotes(deviceId: deviceId, walletId: walletId.id, type: .sell, assetId: asset.id, request: request)
    }

    func validators(
        availableBalance: BigInt,
        selectedQuote: FiatQuote?
    ) -> [any TextValidator] {
        let rangeValidator = FiatRangeValidator(
            range: BigInt(config.minimumAmount)...BigInt(config.maximumAmount),
            minimumValueText: currencyFormatter.string(Double(config.minimumAmount)),
            maximumValueText: currencyFormatter.string(Double(config.maximumAmount))
        )
        let sellValidator = FiatSellValidator(
            quote: selectedQuote,
            availableBalance: availableBalance,
            asset: asset
        )
        return [.assetAmount(decimals: 0, validators: [rangeValidator, sellValidator])]
    }
}
