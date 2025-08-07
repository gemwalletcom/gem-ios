// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Primitives
import Formatters
import Style
import Components
import Foundation

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

public struct AmountDisplayFormatting: Sendable {
    public let sign: AmountDisplaySign
    public let style: ValueFormatter
    public let currencyCode: String
    public let showFiat: Bool

    public init(
        sign: AmountDisplaySign = .none,
        style: ValueFormatter = .auto,
        currencyCode: String,
        showFiat: Bool = true
    ) {
        self.sign = sign
        self.style = style
        self.currencyCode = currencyCode
        self.showFiat = showFiat
    }
}

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

    public var showFiat: Bool {
        switch self {
        case .numeric(let viewModel): viewModel.showFiat
        case .symbol(let viewModel): viewModel.showFiat
        }
    }

    func withFiatVisibility(_ visible: Bool) -> AmountDisplay {
        switch self {
        case .numeric(let vm):
            let fmt = AmountDisplayFormatting(
                sign: vm.formatting.sign,
                style: vm.formatting.style,
                currencyCode: vm.formatting.currencyCode,
                showFiat: visible
            )
            return .numeric(NumericViewModel(data: vm.data, formatting: fmt))
        case .symbol:
            return self
        }
    }
}
