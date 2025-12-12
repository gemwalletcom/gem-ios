// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct SwappableChainsProviderMock: SwappableChainsProvider {
    private let chains: [Chain]

    public init(chains: [Chain] = []) {
        self.chains = chains
    }

    public func supportedChains() -> [Chain] {
        chains
    }

    public static func mock(chains: [Chain] = []) -> SwappableChainsProviderMock {
        SwappableChainsProviderMock(chains: chains)
    }
}
