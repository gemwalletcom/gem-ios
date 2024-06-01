import Foundation

public struct WalletFiatValue: Codable {
    public var totalValue: Double
    public var price: Double
    public var priceChangePercentage24h: Double
    
    public init(totalValue: Double, price: Double, priceChangePercentage24h: Double) {
        self.totalValue = totalValue
        self.price = price
        self.priceChangePercentage24h = priceChangePercentage24h
    }
}

extension WalletFiatValue {
    public static var empty: WalletFiatValue {
        return WalletFiatValue(totalValue: 0, price: 0, priceChangePercentage24h: 0)
    }
}
