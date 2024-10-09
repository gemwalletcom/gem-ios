import Foundation
import BigInt

public final class BigNumberFormatter: Sendable {
    public let locale: Locale
    public let minimumFractionDigits: Int
    public let maximumFractionDigits: Int
    public let decimalSeparator: String
    public let groupingSeparator: String

    public static let standard: BigNumberFormatter = BigNumberFormatter(locale: Locale(identifier: "en_US"))

    public init(locale: Locale = .current,
                minimumFractionDigits: Int = 0,
                maximumFractionDigits: Int = Int.max,
                groupingSeparator: String? = nil
    ) {
        self.locale = locale
        self.minimumFractionDigits = minimumFractionDigits
        self.maximumFractionDigits = maximumFractionDigits
        self.decimalSeparator = locale.decimalSeparator ?? "."
        self.groupingSeparator = groupingSeparator ?? (locale.groupingSeparator ?? ",")
    }

    public func number(from string: String, decimals: Int) throws -> BigInt {
        guard let decimalIndex = string.firstIndex(where: { String($0) == decimalSeparator }) else {
            if let value = BigInt(string).flatMap({ $0 * BigInt(10).power(decimals) }) {
                return value
            }
            throw AnyError("unable to get number for \(string)")
        }
        
        let fractionalDigits = string.distance(from: string.index(after: decimalIndex), to: string.endIndex)

        var fullString = string
        if fractionalDigits > decimals {
            let integerPartString = string[..<string.index(after: decimalIndex)]
            let fractionPartString = string[string.index(after: decimalIndex)...]

            let endIndex = fractionPartString.index(fractionPartString.startIndex, offsetBy: decimals)
            let trimmedFractionString = fractionPartString[..<endIndex]

            fullString = String(integerPartString + trimmedFractionString)
        }

        fullString.remove(at: decimalIndex)

        guard let number = BigInt(fullString) else {
            throw AnyError("unable to get number for \(fullString)")
        }

        if fractionalDigits < decimals {
            return number * BigInt(10).power(decimals - fractionalDigits)
        } else {
            return number
        }
    }

    public func number(from value: Int, decimals: Int) -> BigInt {
         return BigInt(value) * BigInt(10).power(decimals)
    }

    public func string(from number: BigInt, decimals: Int) -> String {
        let dividend = BigInt(10).power(decimals)
        let (integerPart, remainder) = number.quotientAndRemainder(dividingBy: dividend)
        let integerString = integerString(from: integerPart)
        let fractionalString = fractionalString(from: BigInt(sign: .plus, magnitude: remainder.magnitude), decimals: decimals)
        if fractionalString.isEmpty {
            return integerString
        }
        return "\(integerString)\(decimalSeparator)\(fractionalString)"
    }

    public func decimal(from number: BigInt, decimals: Int) -> Decimal? {
        let dividend = BigInt(10).power(decimals)
        let (integerPart, remainder) = number.quotientAndRemainder(dividingBy: dividend)
        let integerString = integerPart.description
        let fractionalString = fractionalString(from: BigInt(sign: .plus, magnitude: remainder.magnitude), decimals: decimals)
        if fractionalString.isEmpty {
            return Decimal(string: integerString)
        }
        return Decimal(string: "\(integerString)\(decimalSeparator)\(fractionalString)", locale: locale)
    }
    
    public func double(from number: BigInt, decimals: Int) -> Double? {
        guard let decimal = decimal(from: number, decimals: decimals) else {
            return .none
        }
        return decimal.doubleValue
    }
}

// MARK: - Private

extension BigNumberFormatter {
    private func integerString(from bigInt: BigInt) -> String {
        var resultString = bigInt.description
        let isNegative = bigInt.sign == .minus
        let endIndex = isNegative ? 1 : 0

        for offset in stride(from: resultString.count - 3, to: endIndex, by: -3) {
            let index = resultString.index(resultString.startIndex, offsetBy: offset)
            resultString.insert(contentsOf: groupingSeparator, at: index)
        }

        return resultString
    }

    private func fractionalString(from number: BigInt, decimals: Int) -> String {
        var number = number
        let digits = number.description.count

        if number == 0 || decimals - digits >= maximumFractionDigits {
            return String(repeating: .zero, count: minimumFractionDigits)
        }

        if decimals < minimumFractionDigits {
            number *= BigInt(10).power(minimumFractionDigits - decimals)
        }
        if decimals > maximumFractionDigits {
            let divisor = BigInt(10).power(decimals - maximumFractionDigits)
            if number > divisor {
                number /= divisor
            }
        }

        var string = number.description
        if digits < decimals {
            string = String(repeating: .zero, count: decimals - digits) + string
        }
        if let lastNonZeroIndex = string.reversed().firstIndex(where: { $0 != "0" })?.base {
            let numberOfZeros = string.distance(from: string.startIndex, to: lastNonZeroIndex)
            if numberOfZeros > minimumFractionDigits {
                let newEndIndex = string.index(string.startIndex, offsetBy: numberOfZeros - minimumFractionDigits)
                string = String(string[string.startIndex..<newEndIndex])
            }
        }

        return string
    }
}
