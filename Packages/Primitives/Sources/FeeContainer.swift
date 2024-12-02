// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

public enum FeeOption: Sendable {
    case tokenAccountCreation
}

public typealias FeeOptionMap = [FeeOption: BigInt]

public struct Fee: Sendable {
    public let fee: BigInt
    public let gasPriceType: GasPriceType
    public let gasLimit: BigInt
    public let options: FeeOptionMap

    public let feeRates: [FeeRate]

    public var gasPrice: BigInt {
        return gasPriceType.gasPrice
    }
    
    public var minerFee: BigInt {
        return gasPriceType.minerFee
    }
    
    public init(
        fee: BigInt,
        gasPriceType: GasPriceType,
        gasLimit: BigInt,
        options: FeeOptionMap = [:],
        feeRates: [FeeRate] = []
    ) {
        self.fee = fee
        self.gasPriceType = gasPriceType
        self.gasLimit = gasLimit
        self.options = options
        self.feeRates = feeRates
    }
    
    public var totalFee: BigInt {
        return fee + optionsFee
    }

    public var optionsFee: BigInt {
        options.map { $0.value }.reduce(0, +)
    }

    public func withOptions(_ feeOptions: [FeeOption]) -> Fee {
        return Fee(
            fee: fee + options.filter { feeOptions.contains($0.key) }.map { $0.value }.reduce(0, +),
            gasPriceType: gasPriceType,
            gasLimit: gasLimit,
            feeRates: feeRates
        )
    }
}

// MARK: - Equatable

extension Fee: Equatable { }
