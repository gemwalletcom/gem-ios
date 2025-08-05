// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

// TODO: - probably move to some chain gemstone-config?

public struct AgentConfig: Sendable {
    public let chain: Chain

    public init(chain: Chain) {
        self.chain = chain
    }

    public var addressKeyPrefix: String {
        "\(agentPrefix)_address"
    }

    public var privateKeyPrefix: String {
        "\(agentPrefix)_private_key"
    }

    private var agentPrefix: String {
        switch chain.type {
        case .hyperCore: "hyperliquid_agent"
        default: fatalError("Agent keystore not supported for \(chain.type)")
        }
    }
}
