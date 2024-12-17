// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components
import SwiftUI
import GemstonePrimitives
import Style

struct AssetIdViewModel {
    let assetId: AssetId
    let assetFormatter: AssetImageFormatter

    init(
        assetId: AssetId,
        assetFormatter: AssetImageFormatter = AssetImageFormatter()
    ) {
        self.assetId = assetId
        self.assetFormatter = assetFormatter
    }
    
    private var imageURL: URL? {
        assetFormatter.getURL(for: assetId)
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
    
    var chainImagePlaceholder: Image {
        ChainViewModel(chain: assetId.chain).image
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
