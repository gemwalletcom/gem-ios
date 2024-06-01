import Foundation
import SwiftUI
import Primitives
import Style
import Store

struct PriceViewModel {
    let price: Price?
    
    let currencyFormatter = CurrencyFormatter.currency()
    let percentFormatter = CurrencyFormatter.percent
    var customCurrency = CurrencyFormatter()
    
    init(price: Price?) {
        self.price = price
        customCurrency.includePlusSign = true
        customCurrency.currencyCode = Preferences.standard.currency
    }
    
    var isPriceAvailable: Bool {
        guard let price = price else {
            return false
        }
        return !(price.price == 0 && price.priceChangePercentage24h == 0)
    }
    
    var priceAmountText: String {
        guard let price = price else { return "" }
        return currencyFormatter.string(price.price)
    }
    
    //TODO: Reduce number of formatters.
    var priceAmountPositiveText: String {
        guard let price = price else { return "" }
        return customCurrency.string(price.price)
    }
    
    var priceAmountColor: Color {
        guard let price = price else { return Colors.gray }
        if price.price == 0 {
            return Colors.grayLight
        } else if price.price >= 0 {
            return Colors.green
        }
        return Colors.red
    }
    
    private var priceChange: Double? {
        return price?.priceChangePercentage24h ?? .none
    }
    
    var priceChangeText: String {
        guard let priceChange = priceChange else { return "" }
        return percentFormatter.string(priceChange)
    }
    
    var priceChangeTextColor: Color {
        Self.priceChangeTextColor(value: priceChange)
    }
    
    static func priceChangeTextColor(value: Double?) -> Color {
        if value == 0 {
            return Colors.grayLight
        } else if value ?? 0 >= 0 {
            return Colors.green
        }
        return Colors.red
    }
    
    var priceChangeTextBackgroundColor: Color {
        if priceChange == 0 {
            return Colors.grayVeryLight
        } else if priceChange ?? 0 > 0 {
            return Colors.greenLight
        }
        return Colors.redLight
    }
    
    func fiatAmountText(amount: Double) -> String {
        return currencyFormatter.string(amount)
    }
    
    func amountWithFiatText(amount: String, fiatAmount: Double) -> String {
        return String(
            format: "%@ (%@)",
            amount,
            fiatAmountText(amount: fiatAmount)
        )
    }
}
