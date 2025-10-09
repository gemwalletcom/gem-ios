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
            .hyperCore,
        ],
        EVMChain.allCases.compactMap { Chain(rawValue: $0.rawValue) },
    ]
    .flatMap { $0 }

    public static let allChains: [Chain] = Chain.allCases

    public static let enabledByDefault: [AssetId] = [
        AssetId(chain: .bitcoin),
        AssetId(chain: .ethereum),
        AssetId(chain: .solana),
        AssetId(chain: .smartChain),
        AssetId(chain: .tron),
    ]
}
