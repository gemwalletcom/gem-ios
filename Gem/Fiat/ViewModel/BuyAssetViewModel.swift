import Foundation
import Primitives
import SwiftUI
import GemAPI
import Components
import Style

class BuyAssetViewModel: ObservableObject {
    private let assetAddress: AssetAddress
    private let fiatService: GemAPIFiatService

    @Published var input: BuyAssetInputViewModel
    @Published var state: StateViewType<Bool> = .loading

    init(
        assetAddress: AssetAddress,
        fiatService: GemAPIFiatService = GemAPIService(),
        input: BuyAssetInputViewModel
    ) {
        self.assetAddress = assetAddress
        self.fiatService = fiatService
        self.input = input
    }

    var asset: Asset {
        assetAddress.asset
    }

    var address: String {
        assetAddress.address
    }

    var title: String {
        Localized.Buy.title(asset.name)
    }

    var amounts: [[Double]] {
        BuyAssetInputViewModel.availableDefaultAmounts
    }

    var amount: Double {
        input.amount
    }

    var shouldDisalbeContinueButton: Bool {
        state.isLoading || state.isNoData
    }
}

// MARK: - Business Logic

extension BuyAssetViewModel {
    func cryptoAmountText(for quote: FiatQuote?) -> String {
        guard let quote = quote else { return " " }
        return "~\(quote.cryptoAmount.rounded(toPlaces: 4)) \(asset.symbol)"
    }

    func rateText(for quote: FiatQuote) -> String {
        let rate = (quote.fiatAmount / quote.cryptoAmount).rounded(toPlaces: 2)
        return "1 \(asset.symbol) ~ $\(rate)"
    }

    func getQuotes(for asset: Asset, amount: Double) async {
        await MainActor.run {
            self.input.amount = amount
            self.input.quote = nil
            self.input.quotes = []
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

            await MainActor.run {
                if !quotes.isEmpty {
                    let inputViewModel = BuyAssetInputViewModel(amount: amount, quote: quotes.first, quotes: quotes)
                    self.input = inputViewModel
                    self.state = .loaded(true)
                } else {
                    self.state = .noData
                }
            }
        } catch {
            await MainActor.run {
                self.state = .error(error)
            }
        }
    }
}
