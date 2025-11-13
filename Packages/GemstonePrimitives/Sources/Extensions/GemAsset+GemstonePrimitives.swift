// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemAssetType {
    public func map() -> AssetType {
        switch self {
        case .native: .native
        case .erc20: .erc20
        case .bep20: .bep20
        case .spl: .spl
        case .spl2022: .spl2022
        case .trc20: .trc20
        case .token: .token
        case .ibc: .ibc
        case .jetton: .jetton
        case .synth: .synth
        case .asa: .asa
        case .perpetual: .perpetual
        case .spot: .spot
        }
    }
}

extension AssetType {
    public func map() -> GemAssetType {
        switch self {
        case .native: .native
        case .erc20: .erc20
        case .bep20: .bep20
        case .spl: .spl
        case .spl2022: .spl2022
        case .trc20: .trc20
        case .token: .token
        case .ibc: .ibc
        case .jetton: .jetton
        case .synth: .synth
        case .asa: .asa
        case .perpetual: .perpetual
        case .spot: .spot
        }
    }
}

extension GemAsset {
    public func map() throws -> Asset {
        Asset(
            id: try AssetId(id: id),
            name: name,
            symbol: symbol,
            decimals: decimals,
            type: assetType.map()
        )
    }
}

extension Asset {
    public func map() -> GemAsset {
        GemAsset(
            id: id.identifier,
            chain: id.chain.rawValue,
            tokenId: id.tokenId,
            name: name,
            symbol: symbol,
            decimals: decimals,
            assetType: type.map()
        )
    }
}
