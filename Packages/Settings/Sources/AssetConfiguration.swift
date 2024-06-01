import Foundation
import Primitives

public struct AssetConfiguration {
    
    public static var supportedChainsWithTokens: [Chain] = [
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

    public static var allChains: [Chain] = [
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
    
    
    
    public static var enabledByDefault: [AssetId] =  [
        Asset(.bitcoin).id,
        Asset(.ethereum).id,
        Asset(.solana).id,
        Asset(.smartChain).id,
    ]
}
