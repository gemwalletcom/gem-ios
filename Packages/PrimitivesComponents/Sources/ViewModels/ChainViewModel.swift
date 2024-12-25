// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import GemstonePrimitives
import SwiftUI
import Components

public struct ChainViewModel: Sendable {
    private let chain: Chain

    public init(chain: Chain) {
        self.chain = chain
    }

    public var title: String { Asset(chain).name }
    public var image: Image { ChainImage(chain: chain).image }
}

// MARK: - Identifiable

extension ChainViewModel: Identifiable {
    public var id: String { chain.rawValue }
}

// MARK: - SimpleListItemViewable

extension ChainViewModel: SimpleListItemViewable {}
