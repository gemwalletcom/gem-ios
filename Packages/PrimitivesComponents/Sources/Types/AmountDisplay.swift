// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Primitives
import Formatters
import Style
import Components
import Foundation

public protocol AmountDisplayable: Sendable {
    var amount: TextValue { get }
    var fiat: TextValue? { get }
    var assetImage: AssetImage? { get }
}

public enum AmountDisplaySign: Sendable {
    case incoming, outgoing, none

    public init(_ direction: TransactionDirection?) {
        switch direction {
        case .incoming: self = .incoming
        case .outgoing: self = .outgoing
        case .selfTransfer, .none: self = .none
        }
    }
}

public struct AmountDisplayStyle: Sendable {
    public let sign: AmountDisplaySign
    public let formatter: ValueFormatter
    public let currencyCode: String
    public let textStyle: TextStyle?

    public init(
        sign: AmountDisplaySign = .none,
        formatter: ValueFormatter = .auto,
        currencyCode: String,
        textStyle: TextStyle? = nil
    ) {
        self.sign = sign
        self.formatter = formatter
        self.currencyCode = currencyCode
        self.textStyle = textStyle
    }
}

public enum AmountDisplay: Sendable {
    case numeric(NumericViewModel)
    case symbol(SymbolViewModel)
}

extension AmountDisplay: AmountDisplayable {
    public var amount: TextValue {
        switch self {
        case .numeric(let viewModel): viewModel.amount
        case .symbol(let viewModel): viewModel.amount
        }
    }

    public var fiat: TextValue? {
        switch self {
        case .numeric(let viewModel): viewModel.fiat
        case .symbol(let viewModel): viewModel.fiat
        }
    }

    public var assetImage: AssetImage? {
        switch self {
        case .numeric(let viewModel): viewModel.assetImage
        case .symbol(let viewModel): viewModel.assetImage
        }
    }

    func fiatVisibility(_ visible: Bool) -> AmountDisplay {
        switch self {
        case .numeric(let model):
            let style = AmountDisplayStyle(
                sign: model.style.sign,
                formatter: model.style.formatter,
                currencyCode: model.style.currencyCode,
                textStyle: model.style.textStyle
            )
            return .numeric(
                NumericViewModel(
                    data: AssetValuePrice(
                        asset: model.data.asset,
                        value: model.data.value,
                        price: visible ? model.data.price : nil),
                    style: style
                )
            )
        case .symbol:
            return self
        }
    }
}

// MARK: - FACTORY

extension AmountDisplay {
    static func symbol(
        asset: Asset
    ) -> AmountDisplay {
        .symbol(SymbolViewModel(asset: asset))
    }

    static func numeric(
        data: AssetValuePrice,
        style: AmountDisplayStyle
    ) -> AmountDisplay {
        .numeric(NumericViewModel(data: data, style: style))
    }

    static func numeric(
        asset: Asset,
        price: Price? = nil,
        value: BigInt,
        direction: TransactionDirection? = nil,
        currency: String,
        formatter: ValueFormatter = .full,
        textStyle: TextStyle? = nil
    ) -> AmountDisplay {
        .numeric(
            data: AssetValuePrice(asset: asset, value: value, price: price),
            style: AmountDisplayStyle(
                sign: .init(direction),
                formatter: formatter,
                currencyCode: currency,
                textStyle: textStyle
            )
        )
    }

    static func currency(
        value: Double,
        currencyCode: String,
        textStyle: TextStyle? = nil
    ) -> TextValue {
        let prefix = if value > 0 {
            "+"
        } else if value < 0 {
            ""
        } else {
            ""
        }

        let color = if value > 0 {
            Colors.green
        } else if value < 0 {
            Colors.red
        } else {
            Colors.black
        }

        let formatter = CurrencyFormatter(type: .currency, currencyCode: currencyCode)
        let viewStyle = textStyle ?? TextStyle(font: .body, color: color, fontWeight: .medium)

        return TextValue(
            text: prefix + formatter.string(value),
            style: viewStyle
        )
    }
}
