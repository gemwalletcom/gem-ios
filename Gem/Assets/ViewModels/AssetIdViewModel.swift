// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components
import SwiftUI
import GemstonePrimitives

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
    
    private var imageURL: URL {
        assetFormatter.getURL(for: assetId)
    }
    
    public var assetImage: AssetImage {
        return AssetImage(
            type: assetId.assetType?.rawValue ?? .empty,
            imageURL: imageURL,
            placeholder: imagePlaceholder,
            chainPlaceholder: chainPlaceholder
        )
    }
    
    var chainImagePlaceholder: Image {
        switch assetId.chain {
        case .bitcoin: Image(.bitcoin)
        case .litecoin: Image(.litecoin)
        case .ethereum: Image(.ethereum)
        case .smartChain: Image(.smartchain)
        case .solana: Image(.solana)
        case .polygon: Image(.polygon)
        case .thorchain: Image(.thorchain)
        case .cosmos: Image(.cosmos)
        case .osmosis: Image(.osmosis)
        case .arbitrum: Image(.arbitrum)
        case .ton: Image(.ton)
        case .tron: Image(.tron)
        case .doge: Image(.doge)
        case .optimism: Image(.optimism)
        case .aptos: Image(.aptos)
        case .base: Image(.base)
        case .avalancheC: Image(.avalanchec)
        case .sui: Image(.sui)
        case .xrp: Image(.xrp)
        case .opBNB: Image(.opbnb)
        case .fantom: Image(.fantom)
        case .gnosis:  Image(.gnosis)
        case .celestia: Image(.celestia)
        case .injective: Image(.injective)
        case .sei: Image(.sei)
        case .manta: Image(.manta)
        case .blast: Image(.blast)
        case .noble: Image(.noble)
        case .zkSync: Image(.zksync)
        case .linea: Image(.linea)
        case .mantle: Image(.mantle)
        case .celo: Image(.celo)
        case .near: Image(.near)
        }
    }
    
    private var imagePlaceholder: Image? {
        switch assetId.type {
        case .native:
            return chainImagePlaceholder
        case .token:
            return .none
        }
    }
    
    private var chainPlaceholder: Image? {
        switch assetId.type {
        case .native:
            return .none
        case .token:
            return chainImagePlaceholder
        }
    }
}
