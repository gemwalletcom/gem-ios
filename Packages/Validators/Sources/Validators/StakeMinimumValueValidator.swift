// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt
import Formatters

public struct StakeMinimumValueValidator: ValueValidator {
    private let available: BigInt
    private let minimumValue: BigInt
    private let reservedForFee: BigInt
    private let asset: Asset

    public init(available: BigInt, minimumValue: BigInt, reservedForFee: BigInt, asset: Asset) {
        self.available = available
        self.minimumValue = minimumValue
        self.reservedForFee = reservedForFee
        self.asset = asset
    }

    public func validate(_ value: BigInt) throws {
        if value <= available, value >= minimumValue + reservedForFee {
            return
        }
        if value < minimumValue {
            throw TransferError.minimumAmount(asset: asset, required: minimumValue)
        }
        if available < value + reservedForFee || value < minimumValue {
            let formatter = ValueFormatter(style: .auto)
            throw TransferError.insufficientStakeBalance(
                total: formatter.string(minimumValue + reservedForFee, asset: asset),
                minimum: formatter.string(minimumValue, decimals: asset.decimals.asInt),
                reserved: formatter.string(reservedForFee, decimals: asset.decimals.asInt)
            )
        }
    }

    public var id: String { "StakeMinimumValueValidator<\(asset.symbol)>" }
}
