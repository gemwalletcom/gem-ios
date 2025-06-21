// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Formatters

struct FiatAmountFormatter {
    let valueFormatter: ValueFormatter
    
    private let decimals: Int

    init(valueFormatter: ValueFormatter, decimals: Int) {
        self.valueFormatter = valueFormatter
        self.decimals = decimals
    }

    func format(amount: Double, for type: FiatQuoteType) -> String {
        switch type {
        case .buy:
            return String(Int(amount))
        case .sell:
            guard let bigIntNumber = try? valueFormatter.inputNumber(from: String(amount), decimals: decimals),
                  !bigIntNumber.isZero else {
                return ""
            }
            return valueFormatter.string(bigIntNumber, decimals: decimals)
        }
    }

    func parseAmount(from text: String, for type: FiatQuoteType) -> Double {
        switch type {
        case .buy:
            return Double(text) ?? .zero
        case .sell:
            if let bigIntNumber = try? valueFormatter.inputNumber(from: text, decimals: decimals),
               let doubleNumber = try? valueFormatter.double(from: bigIntNumber, decimals: decimals) {
                return doubleNumber
            }
            return Double(text) ?? .zero
        }
    }

    func formatCryptoValue(fiatAmount: Double, type: FiatQuoteType) -> String? {
        guard type == .sell else { return nil }
        if let value = try? valueFormatter.inputNumber(from: String(fiatAmount), decimals: decimals) {
            return String(value)
        }
        return nil
    }
}
