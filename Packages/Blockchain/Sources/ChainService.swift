// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient

public struct ChainService {
    
    let chain: Chain
    let url: URL

    public init(
        chain: Chain,
        url: URL
    ) {
        self.chain = chain
        self.url = url
    }
    
    public static func service(chain: Chain, with url: URL) -> ChainServiceable {
        switch chain.type {
        case .solana:
            return SolanaService(chain: chain, provider: ProviderFactory.create(with: url))
        case .ethereum:
            return EthereumService(
                chain: EVMChain(rawValue: chain.rawValue)!,
                provider: ProviderFactory.create(with: url)
            )
        case .cosmos:
            return CosmosService(chain: CosmosChain(rawValue: chain.rawValue)!, provider: ProviderFactory.create(with: url))
        case .ton:
            return TonService(chain: chain, provider: ProviderFactory.create(with: url))
        case .tron:
            return TronService(chain: chain, provider: ProviderFactory.create(with: url))
        case .bitcoin:
            return BitcoinService(
                chain: BitcoinChain(rawValue: chain.rawValue)!,
                provider: ProviderFactory.create(with: url)
            )
        case .aptos:
            return AptosService(chain: chain, provider: ProviderFactory.create(with: url))
        case .sui:
            return SuiService(chain: chain, provider: ProviderFactory.create(with: url))
        case .xrp:
            return XRPService(chain: chain, provider: ProviderFactory.create(with: url))
        case .near:
            return NearService(chain: chain, provider: ProviderFactory.create(with: url))
        }
    }
}

extension ChainService: ChainBalanceable {
    public func coinBalance(for address: String) async throws -> AssetBalance {
        return try await Self.service(chain: chain, with: url)
            .coinBalance(for: address)
    }
    
    public func tokenBalance(for address: String, tokenIds: [AssetId]) async throws -> [AssetBalance] {
        return try await Self.service(chain: chain, with: url)
            .tokenBalance(for: address, tokenIds: tokenIds)
    }
}

extension ChainService: ChainFeeCalculateable {
    public func fee(input: FeeInput) async throws -> Fee {
        return try await Self.service(chain: chain, with: url)
            .fee(input: input)
    }
}

extension ChainService: ChainTransactionPreloadable {
    public func load(input: TransactionInput) async throws -> TransactionPreload {
        return try await Self.service(chain: chain, with: url)
            .load(input: input)
    }
}

extension ChainService: ChainBroadcastable {
    public func broadcast(data: String, options: BroadcastOptions) async throws -> String {
        return try await Self.service(chain: chain, with: url)
            .broadcast(data: data, options: options)
    }
}

extension ChainService: ChainTransactionStateFetchable {
    public func transactionState(for id: String, senderAddress: String) async throws -> TransactionChanges {
        return try await Self.service(chain: chain, with: url)
            .transactionState(for: id, senderAddress: senderAddress)
    }
}

extension ChainService: ChainStakable {
    public func getValidators(apr: Double) async throws -> [DelegationValidator] {
        return try await Self.service(chain: chain, with: url)
            .getValidators(apr: apr)
    }
    
    public func getStakeDelegations(address: String) async throws -> [DelegationBase] {
        return try await Self.service(chain: chain, with: url)
            .getStakeDelegations(address: address)
    }
}

extension ChainService: ChainTokenable {
    public func getTokenData(tokenId: String) async throws -> Asset {
        guard let _ = chain.assetId.assetType else {
            throw TokenValidationError.invalidMetadata
        }
        
        let asset = try await Self.service(chain: chain, with: url).getTokenData(tokenId: tokenId)
        
        if asset.name.isEmpty || asset.symbol.isEmpty {
            throw TokenValidationError.invalidMetadata
        }
        
        return asset
    }
    
    public func getIsTokenAddress(tokenId: String) -> Bool {
        return Self.service(chain: chain, with: url)
            .getIsTokenAddress(tokenId: tokenId)
    }
}

extension ChainService: ChainIDFetchable {
    public func getChainID() async throws -> String {
        return try await Self.service(chain: chain, with: url)
            .getChainID()
    }
}
