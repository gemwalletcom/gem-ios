import Foundation
import Primitives
import SwiftUI
import GemAPI
import Components
import Style

@Observable
class BuyAssetViewModel {
    static let quoteTaskDebounceTimeout = Duration.milliseconds(300)

    private let fiatService: GemAPIFiatService
    private let assetAddress: AssetAddress

    var input: BuyAssetInput
    var state: StateViewType<[FiatQuote]> = .loading

    init(
        fiatService: GemAPIFiatService = GemAPIService(),
        assetAddress: AssetAddress,
        input: BuyAssetInput
    ) {
        self.assetAddress = assetAddress
        self.fiatService = fiatService
        self.input = input
    }

    var title: String { Localized.Buy.title(asset.name) }
    var actionButtonTitle: String { Localized.Common.continue }
    var providerTitle: String { Localized.Common.provider }
    var rateTitle: String { Localized.Buy.rate }
    var errorTitle: String { Localized.Errors.errorOccured }
    var emptyTitle: String { input.amount == 0 ? emptyAmountTitle : emptyQuotesTitle}

    var currencySymbol: String { "$" }

    var asset: Asset {
        assetAddress.asset
    }

    var randomAmount: Double? {
        BuyAssetInput.randomAmount(current: input.amount)
    }

    var suggestedAmounts: [Double] {
        BuyAssetInput.suggestedAmounts
    }

    var assetImage: AssetImage {
        AssetIdViewModel(assetId: asset.id).assetImage
    }

    var shouldDisableContinueButton: Bool {
        state.isNoData || state.isError
    }

    var cryptoAmountValue: String {
        guard let quote = input.quote else { return "" }
        return "≈ \(quote.cryptoAmount.rounded(toPlaces: 4)) \(asset.symbol)"
    }

    func rateValue(for quote: FiatQuote) -> String {
        let rate = (quote.fiatAmount / quote.cryptoAmount).rounded(toPlaces: 2)
        return "1 \(asset.symbol) ≈ \(currencySymbol)\(rate)"
    }

    func buttonTitle(amount: Double) -> String {
        "\(currencySymbol)\(Int(amount))"
    }

    private var address: String { assetAddress.address }
    private var amount: Double { input.amount }

    private var emptyQuotesTitle: String { Localized.Buy.noResults }
    private var emptyAmountTitle: String { Localized.Buy.emptyAmount }
}

// MARK: - Business Logic

extension BuyAssetViewModel {
    func fetch() async {
        await MainActor.run { [self] in
            self.input.quote = nil
            if self.input.amount == 0 {
                self.state = .noData
                return
            }
            self.state = .loading
        }

        do {
            let quotes = try await fiatService.getQuotes(
                asset: asset,
                request: FiatBuyRequest(
                    assetId: asset.id.identifier,
                    fiatCurrency: Currency.usd.rawValue,
                    fiatAmount: amount,
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
