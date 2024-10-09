import Foundation
import Primitives

public struct AssetConfiguration: Sendable {

    public static let supportedChainsWithTokens: [Chain] = [
        [
            .solana,
            .ton,
            .sui,
            .aptos,
            .tron,
        ],
        EVMChain.allCases.compactMap { Chain(rawValue: $0.rawValue) }
    ]
    .flatMap { $0 }

    public static let allChains: [Chain] = [
        .bitcoin,
        .litecoin,
        .solana,
        .smartChain,
        .ethereum,
        .polygon,
        .thorchain,
        .cosmos,
        .osmosis,
        .arbitrum,
        .ton,
        .tron,
        .doge,
        .aptos,
        .base,
        .avalancheC,
        .optimism,
        .sui,
        .xrp,
        .opBNB,
        .fantom,
        .gnosis,
        .celestia,
        .injective,
        .sei,
        .manta,
        .blast,
        .noble,
        .zkSync,
        .linea,
        .mantle,
        //.celo, not ready yet
        .near,
    ]

    public static let enabledByDefault: [AssetId] =  [
        AssetId(chain: .bitcoin, tokenId: .none),
        AssetId(chain: .ethereum, tokenId: .none),
        AssetId(chain: .solana, tokenId: .none),
        AssetId(chain: .smartChain, tokenId: .none),
    ]
}
