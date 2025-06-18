// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt
import Primitives
import Formatters

public struct AmountValidator: FormattedValidator {
    public enum Source: Sendable {
        case asset
        case fiat(price: AssetPrice?, converter: ValueConverter)
    }

    public typealias Formatted = BigInt

    public let validators: [any ValueValidator<BigInt>]

    private let formatter: ValueFormatter
    private let decimals: Int
    private let source: Source

    public init(
        formatter: ValueFormatter,
        decimals: Int,
        source: Source,
        validators: [any ValueValidator<BigInt>]
    ) {
        self.formatter = formatter
        self.decimals = decimals
        self.source = source
        self.validators = validators
    }

    public var id: String { "AmountValidator<\(Formatted.self)>" }

    public func format(_ text: String) throws -> BigInt {
        let canonical: String

        switch source {
        case .asset:
            canonical = text
        case .fiat(let price, let converter):
            guard let price else { throw TransferError.invalidAmount }
            canonical = (try? converter.convertToAmount(
                fiatValue: text,
                price: price,
                decimals: decimals
            )).or(.zero)
        }

        return try formatter.inputNumber(
            from: canonical,
            decimals: decimals
        )
    }
}

public extension TextValidator where Self == AmountValidator {
    static func amount(
         source: AmountValidator.Source,
         formatter: ValueFormatter = .init(style: .full),
         decimals: Int,
         validators: [any ValueValidator<BigInt>]
     ) -> Self {
         .init(
             formatter: formatter,
             decimals: decimals,
             source: source,
             validators: validators
         )
     }
    
    static func assetAmount(
        formatter: ValueFormatter = .init(style: .full),
        decimals: Int,
        validators: [any ValueValidator<BigInt>]
    ) -> Self {
        .init(
            formatter: formatter,
            decimals: decimals,
            source: .asset,
            validators: validators
        )
    }

    static func fiatAmount(
        formatter: ValueFormatter = .init(style: .full),
        converter: ValueConverter = .init(),
        price: AssetPrice?,
        decimals: Int,
        validators: [any ValueValidator<BigInt>]
    ) -> Self {
        .init(
            formatter: formatter,
            decimals: decimals,
            source: .fiat(price: price, converter: converter),
            validators: validators
        )
    }
}
