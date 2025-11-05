// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemAssetType {
    public func map() -> AssetType {
        switch self {
        case .native: return .native
        case .erc20: return .erc20
        case .bep20: return .bep20
        case .spl: return .spl
        case .spl2022: return .spl2022
        case .trc20: return .trc20
        case .token: return .token
        case .ibc: return .ibc
        case .jetton: return .jetton
        case .synth: return .synth
        case .asa: return .asa
        case .perpetual: return .perpetual
        }
    }
}

extension AssetType {
    public func map() -> GemAssetType {
        switch self {
        case .native: return .native
        case .erc20: return .erc20
        case .bep20: return .bep20
        case .spl: return .spl
        case .spl2022: return .spl2022
        case .trc20: return .trc20
        case .token: return .token
        case .ibc: return .ibc
        case .jetton: return .jetton
        case .synth: return .synth
        case .asa: return .asa
        case .perpetual: return .perpetual
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
