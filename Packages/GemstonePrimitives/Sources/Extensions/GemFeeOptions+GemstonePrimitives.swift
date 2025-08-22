// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives
import BigInt

extension GemFeeOptions {
    public func map() throws -> FeeOptionMap {
        var feeOptions: FeeOptionMap = [:]
        for (option, value) in options {
            let feeOption: FeeOption
            switch option {
            case .tokenAccountCreation:
                feeOption = .tokenAccountCreation
            }
            feeOptions[feeOption] = try BigInt.from(string: value)
        }
        return feeOptions
    }
}