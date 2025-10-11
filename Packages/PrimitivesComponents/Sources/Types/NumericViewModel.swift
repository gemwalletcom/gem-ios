import BigInt
import Primitives
import Formatters
import Style
import Components
import SwiftUI

public struct NumericViewModel: Sendable, AmountDisplayable {
    public let data: AssetValuePrice
    public let style: AmountDisplayStyle

    public init(data: AssetValuePrice, style: AmountDisplayStyle) {
        self.data = data
        self.style = style
    }

    public var amount: TextValue {
        let prefix: String = switch style.sign {
        case .incoming where !data.value.isZero:  "+"
        case .outgoing where !data.value.isZero:  "-"
        case .none, .incoming, .outgoing: ""
        }

        let crypto = style.formatter.string(
            data.value,
            decimals: data.asset.decimals.asInt,
            currency: data.asset.symbol
        )
        let viewStyle = style.textStyle ?? TextStyle(
            font: .body,
            color: color,
            fontWeight: .medium
        )
        return TextValue(
            text: prefix + crypto,
            style: viewStyle,
            lineLimit: 1
        )
    }

    public var fiat: TextValue? {
        guard let quote = data.price,
              let value = try? style.formatter.double(
                from: data.value,
                decimals: data.asset.decimals.asInt
              )
        else { return nil }

        let currencyFormatter = CurrencyFormatter(
            type: .currency,
            currencyCode: style.currencyCode
        )
        let style = style.textStyle ?? TextStyle(
            font: .footnote,
            color: Colors.gray,
            fontWeight: .medium
        )

        return TextValue(
            text: currencyFormatter.string(quote.price * value),
            style: style,
            lineLimit: 1
        )
    }

    public var assetImage: AssetImage? {
        AssetViewModel(asset: data.asset).assetImage
    }

    private var color: Color {
        switch style.sign {
        case .incoming: Colors.green
        case .outgoing, .none: Colors.black
        }
    }
}
