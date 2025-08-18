import Style
import Components

public struct SymbolViewModel: Sendable, AmountDisplayable {
    public let symbol: String
    
    public init(symbol: String) {
        self.symbol = symbol
    }
    
    public var amount: TextValue {
        TextValue(
            text: symbol,
            style: TextStyle(
                font: .body,
                color: Colors.black,
                fontWeight: .semibold
            ),
            lineLimit: 1
        )
    }
    
    public var fiat: TextValue? { nil }
}
