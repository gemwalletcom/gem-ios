// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import class Gemstone.Config
import struct Gemstone.SwapConfig
import enum Gemstone.DocsUrl
import enum Gemstone.PublicUrl
import enum Gemstone.RewardsUrl
import enum Gemstone.SocialUrl
import struct Gemstone.StakeChainConfig
import typealias Gemstone.ChainConfig
import typealias Gemstone.WalletConnectConfig
import Primitives

private let utmSource = "gemwallet_ios"

extension Config {
    public static let shared = Config()

    public func swapConfig() -> SwapConfig {
        getSwapConfig()
    }
}

public struct GemstoneConfig {
    public static let shared = Config()
}

public struct Docs {
    public static func url(_ item: DocsUrl) -> URL {
        return URL(string: Config.shared.getDocsUrl(item: item))!
            .withUTM(source: utmSource)
    }
}

public struct RewardsUrlConfig {
    public static func url(_ item: RewardsUrl) -> URL {
        let locale = Locale.current.identifier
        return URL(string: Config.shared.getRewardsUrl(item: item, locale: locale))!
            .withUTM(source: utmSource)
    }
}

public struct PublicConstants {
    public static func url(_ item: PublicUrl) -> URL {
        return URL(string: Config.shared.getPublicUrl(item: item))!
            .withUTM(source: utmSource)
    }
}

public struct Social {
    public static func url(_ item: SocialUrl) -> URL? {
        if let socialUrl = Config.shared.getSocialUrl(item: item), let url = URL(string: socialUrl) {
            return url
        }
        return .none
    }
}

public struct StakeConfig {
    public static func config(chain: StakeChain) -> StakeChainConfig {
        Config.shared.getStakeConfig(chain: chain.rawValue)
    }
}

public struct ChainConfig {
    // store in memory for fast access
    private static let chainConfigs: [Primitives.Chain: Gemstone.ChainConfig] = {
        Primitives.Chain.allCases.reduce(into: [:]) { result, chain in
            result[chain] = Config.shared.getChainConfig(chain: chain.rawValue)
        }
    }()

    public static func config(chain: Primitives.Chain) -> Gemstone.ChainConfig {
        chainConfigs[chain]!
    }
}

public struct WalletConnectConfig {
    public static func config() -> Gemstone.WalletConnectConfig {
        Config.shared.getWalletConnectConfig()
    }
}
