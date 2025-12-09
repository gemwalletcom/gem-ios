// Copyright (c). Gem Wallet. All rights reserved.

import Primitives
import SwiftUI
import Components

public struct ChainViewModel: Sendable {
    private let chain: Chain

    public init(chain: Chain) {
        self.chain = chain
    }

    public var title: String { Asset(chain).name }
    public var image: Image {
        return ChainImage(chain: chain).placeholder
    }
}

// MARK: - Identifiable

extension ChainViewModel: Identifiable {
    public var id: String { chain.rawValue }
}

// MARK: - SimpleListItemViewable

extension ChainViewModel: SimpleListItemViewable {
    public var assetImage: AssetImage {
        AssetImage.image(image)
    }
}
