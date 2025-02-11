import Foundation

public struct AssetConfiguration: Sendable {
    public static let supportedChainsWithTokens: [Chain] = [
        [
            .solana,
            .ton,
            .sui,
            .aptos,
            .tron,
            .aptos,
            .algorand,
            // .xrp, Not complete
            .stellar,
        ],
        EVMChain.allCases.compactMap { Chain(rawValue: $0.rawValue) },
    ]
    .flatMap { $0 }

    public static let allChains: [Chain] = Chain.allCases.asSet()
        .subtracting(Set<Chain>([.celo])) // Exclude unnecessary chains
        .asArray()

    public static let enabledByDefault: [AssetId] = [
        AssetId(chain: .bitcoin, tokenId: .none),
        AssetId(chain: .ethereum, tokenId: .none),
        AssetId(chain: .solana, tokenId: .none),
        AssetId(chain: .smartChain, tokenId: .none),
    ]
}
