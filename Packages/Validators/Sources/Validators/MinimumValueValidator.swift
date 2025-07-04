// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt

public struct MinimumValueValidator<V>: ValueValidator where V: ValueValidatable
{
    private let minimumValue: V
    private let asset: Asset

    public init(minimumValue: V, asset: Asset) {
        self.minimumValue = minimumValue
        self.asset = asset
    }

    public func validate(_ value: V) throws {
        guard value >= minimumValue else {
            if let minimumValue = minimumValue as? BigInt {
                throw TransferError
                    .minimumAmount(
                        asset: asset,
                        required: minimumValue
                    )
            }
            throw TransferError.invalidAmount
        }
    }

    public var id: String { "MinimumValueValidator<\(V.self)>" }
}
