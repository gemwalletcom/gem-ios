// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
@preconcurrency import Gemstone
import Primitives

extension Config {
    public static let shared = Config()

    public func config(for evmChain: EVMChain) -> EvmChainConfig {
        getEvmChainConfig(chain: evmChain.rawValue)
    }

    public func config(for bitcoinChain: BitcoinChain) -> BitcoinChainConfig {
        getBitcoinChainConfig(chain: bitcoinChain.rawValue)
    }
}

public struct Docs {
    public static func url(_ item: Gemstone.DocsUrl) -> URL {
        return URL(string: Config.shared.getDocsUrl(item: item))!
    }
}

public struct Social {
    public static func url(_ item: Gemstone.SocialUrl) -> URL? {
        if let socialUrl = Config.shared.getSocialUrl(item: item), let url = URL(string: socialUrl) {
            return url
        }
        return .none
    }
}

public struct PublicConstants {
    public static func url(_ item: Gemstone.PublicUrl) -> URL {
        return URL(string: Config.shared.getPublicUrl(item: item))!
    }
}

public struct StakeConfig {
    public static func config(chain: StakeChain) -> Gemstone.StakeChainConfig {
        Config.shared.getStakeConfig(chain: chain.rawValue)
    }
}

public struct ChainConfig {
    public static func config(chain: Chain) -> Gemstone.ChainConfig {
        Config.shared.getChainConfig(chain: chain.rawValue)
    }
}

public struct WalletConnectConfig {
    public static func config() -> Gemstone.WalletConnectConfig {
        Config.shared.getWalletConnectConfig()
    }
}

public struct SolanaConfig {
    public static func tokenProgramId(owner: String) -> Optional<SolanaTokenProgramId> {
        guard
            let rawId = Config.shared.getSolanaTokenProgramId(address: owner),
            let id = SolanaTokenProgramId(rawValue: rawId)
        else {
            return .none
        }
        return id
    }
}
