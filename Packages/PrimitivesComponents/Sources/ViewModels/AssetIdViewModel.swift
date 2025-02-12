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
            placeholder: imagePlaceholder,
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
        assetFormatter.getURL(for: assetId)
    }

    private var chainImagePlaceholder: Image {
        ChainImage(chain: assetId.chain).image
    }

    private var imagePlaceholder: Image? {
        switch assetId.type {
        case .native: chainImagePlaceholder
        case .token: .none
        }
    }

    private var chainPlaceholder: Image? {
        switch assetId.type {
        case .native: .none
        case .token: chainImagePlaceholder
        }
    }
}
