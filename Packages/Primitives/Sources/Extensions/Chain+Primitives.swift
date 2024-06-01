import Foundation
import BigInt
import Gemstone

extension Chain {
    public var asset: Asset {
        //TODO: Force unwrap for now, until move Asset to Gemstone
        let assetWrapper = Gemstone.assetWrapper(chain: id)
        return Asset(
            id: AssetId(id: assetWrapper.id)!,
            name: assetWrapper.name,
            symbol: assetWrapper.symbol,
            decimals: assetWrapper.decimals,
            type: AssetType(rawValue: assetWrapper.assetType)!
        )
    }
    
    public var assetId: AssetId {
        return AssetId(chain: self, tokenId: .none)
    }
    
    public var type: ChainType {
        switch self {
        case .bitcoin,
            .doge,
            .litecoin:
            return .bitcoin
        case .ethereum,
            .smartChain,
            .arbitrum,
            .optimism,
            .base,
            .avalancheC,
            .opBNB,
            .fantom,
            .gnosis,
            .manta,
            .blast,
            .zkSync,
            .linea,
            .mantle,
            .celo:
            return .ethereum
        case .solana:
            return .solana
        case .polygon:
            return .ethereum
        case .cosmos,
            .thorchain,
            .osmosis,
            .celestia,
            .injective,
            .sei,
            .noble:
            return .cosmos
        case .ton:
            return .ton
        case .tron:
            return .tron
        case .aptos:
            return .aptos
        case .sui:
            return .sui
        case .xrp:
            return .xrp
        case .near:
            return .near
        }
    }
}

extension Chain: Identifiable {
    public var id: String { rawValue }
}
