import BigInt
import Primitives
import Formatters
import Style
import Components
import SwiftUI

public struct NumericViewModel: Sendable, AmountDisplayable {
    public let data: AssetValuePrice
    public let formatting: AmountDisplayFormatting

    public init(data: AssetValuePrice, formatting: AmountDisplayFormatting) {
        self.data = data
        self.formatting = formatting
    }

    public var showFiat: Bool { formatting.showFiat }

    public var amount: TextValue {
        let prefix: String = switch formatting.sign {
        case .incoming where !data.value.isZero:  "+"
        case .outgoing where !data.value.isZero:  "-"
        case .none, .incoming, .outgoing: ""
        }

        let crypto = formatting.style.string(
            data.value,
            decimals: data.asset.decimals.asInt,
            currency: data.asset.symbol
        )

        return TextValue(
            text: prefix + crypto,
            style: TextStyle(
                font: .body,
                color: color,
                fontWeight: .semibold
            ),
            lineLimit: 1
        )
    }

    public var fiat: TextValue? {
        guard let quote = data.price,
              let value = try? formatting.style.double(
                from: data.value,
                decimals: data.asset.decimals.asInt
              )
        else { return nil }

        let currencyFormatter = CurrencyFormatter(
            type: .currency,
            currencyCode: formatting.currencyCode
        )

        return TextValue(
            text: currencyFormatter.string(quote.price * value),
            style: TextStyle(
                font: .body,
                color: Colors.gray,
                fontWeight: .medium
            ),
            lineLimit: 1
        )
    }

    private var color: Color {
        switch formatting.sign {
        case .incoming: Colors.green
        case .outgoing: Colors.red
        case .none: Colors.black
        }
    }
}
