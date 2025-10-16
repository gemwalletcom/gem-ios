// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
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
        let defaultAssetImage = AssetImage(
            type: assetId.assetType?.rawValue ?? .empty,
            imageURL: imageURL,
            placeholder: imagePlaceholder,
            chainPlaceholder: chainPlaceholder
        )
        switch (assetId.chain, assetId.type) {
        case (.hyperCore, .token):
            if let token = try? assetId.twoSubTokenIds(), let chain = Chain.allCases.first(where: { $0.asset.symbol == token.1} ) {
                let chainAssetImage = AssetIdViewModel(assetId: chain.assetId).assetImage
                return AssetImage(
                    type: defaultAssetImage.type,
                    imageURL: chainAssetImage.imageURL,
                    placeholder: chainAssetImage.placeholder,
                    chainPlaceholder: chainPlaceholder
                )
            }
        default: return defaultAssetImage
        }
        return defaultAssetImage
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
