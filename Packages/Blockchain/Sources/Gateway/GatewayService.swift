// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives
import BigInt
import NativeProviderService

public struct GetewayService: Sendable {
    let gateway: GemGateway
    
    public init(
        provider: NativeProvider
    ) {
        self.gateway = GemGateway(provider: provider)
    }
}

// MARK: - Balances

extension GetewayService {
    public func coinBalance(chain: Primitives.Chain, address: String) async throws -> AssetBalance {
        try await gateway.getBalanceCoin(chain: chain.rawValue, address: address).map()
    }

    public func tokenBalance(chain: Primitives.Chain, address: String, tokenIds: [Primitives.AssetId]) async throws -> [AssetBalance] {
        try await gateway.getBalanceTokens(chain: chain.rawValue, address: address, tokenIds: tokenIds.map(\.id)).map {
            try $0.map()
        }
    }

    public func getStakeBalance(chain: Primitives.Chain, address: String) async throws -> AssetBalance? {
        try await gateway.getBalanceStaking(chain: chain.rawValue, address: address)?.map()
    }
}

// MARK: - Transactions

extension GetewayService {
    public func transactionBroadcast(chain: Primitives.Chain, data: String) async throws -> String {
        try await gateway.transactionBroadcast(chain: chain.rawValue, data: data)
    }
    
    public func transactionStatus(chain: Primitives.Chain, hash: String) async throws -> String {
        try await gateway.getTransactionStatus(chain: chain.rawValue, hash: hash)
    }
}

// MARK: - Staking

extension GetewayService {
    public func validators(chain: Primitives.Chain) async throws -> [DelegationValidator] {
        do {
            let validators = try await gateway.getStakingValidators(chain: chain.rawValue)
                .map { try $0.map() }
            NSLog("validators \(validators)")
            return validators
        } catch {
            NSLog("validators \(error)")
            throw AnyError(error.localizedDescription)
        }
    }

    public func delegations(chain: Primitives.Chain, address: String) async throws -> [DelegationBase] {
        do {
            let delegations = try await gateway.getStakingDelegations(chain: chain.rawValue, address: address)
                .map { try $0.map() }
            NSLog("delegations \(delegations)")
            return delegations
        } catch {
            NSLog("delegations \(error)")
            throw AnyError(error.localizedDescription)
        }
    }
}

extension GemAssetBalance {
    func map() throws -> AssetBalance {
        AssetBalance(
            assetId: try AssetId(id: assetId),
            balance: try balance.map()
        )
    }
}

extension GemBalance {
    func map() throws -> Balance {
        Balance(
            available: try BigInt.from(string: available),
            frozen: try BigInt.from(string: frozen),
            locked: try BigInt.from(string: locked),
            staked: try BigInt.from(string: staked),
            pending: try BigInt.from(string: pending),
            rewards: try BigInt.from(string: rewards),
            reserved: try BigInt.from(string: reserved),
            withdrawable: try BigInt.from(string: withdrawable)
        )
    }
}

extension GemDelegationValidator {
    func map() throws -> DelegationValidator {
        DelegationValidator(
            chain: try Chain(id: chain),
            id: id,
            name: name,
            isActive: isActive,
            commision: commision,
            apr: apr
        )
    }
}

extension GemDelegationBase {
    func map() throws -> DelegationBase {
        DelegationBase(
            assetId: try AssetId(id: assetId),
            state: try DelegationState(id: state),
            balance: balance,
            shares: shares,
            rewards: rewards,
            completionDate: .none, // fix later
            delegationId: delegationId,
            validatorId: validatorId
        )
    }
}

extension DelegationState {
    
    public init(id: String) throws {
        if let state = DelegationState(rawValue: id) {
            self = state
        } else {
            throw AnyError("invalid state: \(id)")
        }
    }
}
