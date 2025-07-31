// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public enum NameRecordState: Equatable, Hashable, Sendable {
    case none
    case loading
    case error
    case complete(NameRecord)
}

public extension NameRecordState {
    var result: NameRecord? {
        switch self {
        case .complete(let result): result
        default: .none
        }
    }
}