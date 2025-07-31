// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwapService
import ChainServiceTestKit
import protocol Gemstone.GemSwapperProtocol

public extension SwapService {
    static func mock(swapper: GemSwapperProtocol = GemSwapperMock()) -> SwapService {
        SwapService(swapper: swapper)
    }
}
