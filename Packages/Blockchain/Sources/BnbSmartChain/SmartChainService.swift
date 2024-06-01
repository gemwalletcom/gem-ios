// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient
import WalletCore

public class SmartChainService {

    let provider: Provider<EthereumProvider>
    let stakeHub: StakeHub

    init(provider: Provider<EthereumProvider>) {
        self.provider = provider
        self.stakeHub = StakeHub()
    }
}

extension SmartChainService {
    public func coinBalance(for address: String) async throws -> AssetBalance {
        async let balanceCall = try provider.request(.balance(address: address))
            .mapResult(BigIntable.self).value
        async let delegationsCall = try getStakeDelegations(address: address)

        let (balance, delegations) = try await(balanceCall, delegationsCall)
        let staked = delegations.filter { $0.state == .active }.map { $0.balanceValue }.reduce(0, +)
        let pending = delegations.filter { $0.state == .undelegating }.map { $0.balanceValue }.reduce(0, +)
        return AssetBalance(
            assetId: Chain.smartChain.assetId,
            balance: Balance(
                available: balance,
                staked: staked,
                pending: pending
            )
        )
    }
}

extension SmartChainService: ChainStakable {
    public func getValidators(apr: Double) async throws -> [DelegationValidator] {
        let limit = try await getMaxElectedValidators()
        let params = [
            "to":StakeHub.reader,
            "data": stakeHub.encodeValidatorsCall(offset: 0, limit: limit)
        ]
        
        let result = try await provider.request(.call(params)).map(as: JSONRPCResponse<String>.self).result
        guard let data = Data(hexString: result) else {
            return []
        }
        let validators = try stakeHub.decodeValidatorsReturn(data: data)
        return validators
    }

    public func getStakeDelegations(address: String) async throws -> [DelegationBase] {
        let limit = try await getMaxElectedValidators()
        async let delegationsCall = try getDelegations(address: address, limit: limit)
        async let undelegationsCall = try getUndelegations(address: address, limit: limit)
        let (delegations, undelegations) = try await (delegationsCall, undelegationsCall)
        return delegations + undelegations
    }

    func getMaxElectedValidators() async throws -> UInt16 {
        let params = [
            "to":StakeHub.address,
            "data": stakeHub.encodeMaxElectedValidators()
        ]

        let result = try await provider.request(.call(params)).map(as: JSONRPCResponse<String>.self).result
        guard 
            let data = Data(hexString: result),
            let value = UInt16(EthereumAbiValue.decodeUInt256(input: data))
        else {
            throw AnyError("Unable to get validators")
        }
        return value
    }

    func getDelegations(address: String, limit: UInt16) async throws -> [DelegationBase] {
        let params = [
            "to":StakeHub.reader,
            "data": try stakeHub.encodeDelegationsCall(address: address, limit: limit)
        ]
        let result = try await provider.request(.call(params)).mapResult(String.self)
        guard let data = Data(hexString: result) else {
            return []
        }
        return try stakeHub.decodeDelegationsResult(data: data)
    }

    func getUndelegations(address: String, limit: UInt16) async throws -> [DelegationBase] {
        let params = [
            "to":StakeHub.reader,
            "data": try stakeHub.encodeUndelegationsCall(address: address, limit: limit)
        ]
        let result = try await provider.request(.call(params)).mapResult(String.self)
        guard let data = Data(hexString: result) else {
            return []
        }
        return try stakeHub.decodeUnelegationsResult(data: data)
    }
}
