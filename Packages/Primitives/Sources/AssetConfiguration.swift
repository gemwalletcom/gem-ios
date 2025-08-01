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
            .xrp,
            .stellar,
            .xrp,
        ],
        EVMChain.allCases.compactMap { Chain(rawValue: $0.rawValue) },
    ]
    .flatMap { $0 }

    public static let allChains: [Chain] = Chain.allCases

    public static let enabledByDefault: [AssetId] = [
        AssetId(chain: .bitcoin, tokenId: .none),
        AssetId(chain: .ethereum, tokenId: .none),
        AssetId(chain: .solana, tokenId: .none),
        AssetId(chain: .smartChain, tokenId: .none),
    ]
}
