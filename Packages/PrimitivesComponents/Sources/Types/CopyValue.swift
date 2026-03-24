// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import Formatters

public enum CopyValue: Sendable, Equatable, Hashable {
    case plain(String)
    case address(value: String, chain: Chain?)

    public var rawValue: String {
        switch self {
        case .plain(let value): value
        case .address(let value, _): value
        }
    }

    public var displayValue: String {
        switch self {
        case .plain(let value): value
        case .address(let value, let chain):
            AddressFormatter(style: .short, address: value, chain: chain).value()
        }
    }
}
