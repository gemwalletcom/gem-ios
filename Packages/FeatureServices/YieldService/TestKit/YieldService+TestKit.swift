// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone

@testable import YieldService

public final class MockYieldService: Sendable {
    public var mockYields: [GemYield] = []
    public var mockPosition: GemYieldPosition?
    public var mockTransaction: GemYieldTransaction?

    public init() {}
}
