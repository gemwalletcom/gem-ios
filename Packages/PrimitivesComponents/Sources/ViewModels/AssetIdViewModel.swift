// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import GemstonePrimitives
import Components

public struct AssetIdViewModel: Sendable {
    private let assetId: AssetId
    private let assetFormatter: AssetImageFormatter

    public init(
        assetId: AssetId,
        assetFormatter: AssetImageFormatter = AssetImageFormatter()
    ) {
        self.assetId = assetId
        self.assetFormatter = assetFormatter
    }

    public var networkAssetImage: AssetImage {
        AssetImage(
            type: .empty,
            imageURL: .none,
            placeholder: ChainImage(chain: assetId.chain).l2Image ?? imagePlaceholder,
            chainPlaceholder: .none
        )
    }

    public var assetImage: AssetImage {
        AssetImage(
            type: assetId.assetType?.rawValue ?? .empty,
            imageURL: imageURL,
            placeholder: imagePlaceholder,
            chainPlaceholder: chainPlaceholder
        )
    }

    private var imageURL: URL? {
        switch assetId.type {
        case .native: .none
        case .token: assetFormatter.getURL(for: assetId)
        }
    }

    private var imagePlaceholder: Image? {
        switch assetId.type {
        case .native: ChainImage(chain: assetId.chain).image
        case .token: .none
        }
    }

    private var chainPlaceholder: Image? {
        switch assetId.type {
        case .native: ChainImage(chain: assetId.chain).l2Image
        case .token: ChainImage(chain: assetId.chain).placeholder
        }
    }
}
