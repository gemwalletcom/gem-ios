import Foundation
import Primitives
import SwiftUI
import GemAPI

class BuyAssetViewModel: ObservableObject {
    
    private let assetAddress: AssetAddress
    private let fiatService: GemAPIFiatService = GemAPIService()

    @Published var amount: Double = 0
    @Published var quote: FiatQuote?
    @Published var quotes: [FiatQuote] = []
    @Published var quoteLoading: Bool = false
    @Published var quoteError: Error?

    init(
        assetAddress: AssetAddress
    ) {
        self.assetAddress = assetAddress
    }
    
    var asset: Asset {
        assetAddress.asset
    }
    
    var address: String {
        assetAddress.address
    }
    
    var title: String {
        return Localized.Buy.title(asset.name)
    }
    
    var defaultaAmount: Int {
        return 50
    }
    
    var amounts: [[Int]] {
        return [
            [50, 100, 200],
            [250, 500, 1000]
        ]
    }
    
    func cryptoAmountText(quote: FiatQuote?) -> String {
        if let quote = quote {
            return "~\(quote.cryptoAmount.rounded(toPlaces: 4)) \(asset.symbol)"
        }
        return " "
    }
    
    func rateText(quote: FiatQuote) -> String {
        return "1 \(asset.symbol) ~ $\((quote.fiatAmount / quote.cryptoAmount).rounded(toPlaces: 2))"
    }
    
    func getQuotes(asset: Asset, amount: Double) async {
        //TODO: Refactor to use state managment
        DispatchQueue.main.async {
            self.amount = amount
            self.quoteLoading = true
            self.quote = nil
            self.quoteError = nil
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
            DispatchQueue.main.async {
                self.quotes = quotes
                self.quote = quotes.first
            }
            
        } catch {
            NSLog("getQuotes error: \(error)")
            DispatchQueue.main.async {
                self.quoteError = error
            }
        }
        
        DispatchQueue.main.async {
            self.quoteLoading = false
        }
    }
}
