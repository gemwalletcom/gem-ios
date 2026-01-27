// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public protocol DebouncableTrigger: Equatable, Sendable {
    var isImmediate: Bool { get }
}
