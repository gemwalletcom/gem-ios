// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient
import WalletCore

final public class SmartChainService: Sendable {
    let provider: Provider<EthereumTarget>
    let stakeHub: StakeHub

    init(provider: Provider<EthereumTarget>) {
        self.provider = provider
        self.stakeHub = StakeHub()
    }
}

extension SmartChainService: ChainStakable {
    func getMaxElectedValidators() async throws -> UInt16 {
        let params = [
            "to":StakeHub.address,
            "data": stakeHub.encodeMaxElectedValidators()
        ]
        let result = try await self.provider.request(.call(params)).map(as: JSONRPCResponse<String>.self).result

        guard
            let data = Data(hexString: result),
            let value = UInt16(EthereumAbiValue.decodeUInt256(input: data))
        else {
            throw AnyError("Unable to get validators")
        }

        return value
    }

    public func getValidators(apr _: Double) async throws -> [DelegationValidator] {
        let limit = try await getMaxElectedValidators()
        let params = [
            "to": StakeHub.reader,
            "data": stakeHub.encodeValidatorsCall(offset: 0, limit: limit),
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
        let calls = [
            try getDelegationsCall(address: address, limit: limit),
            try getUndelegationsCall(address: address, limit: limit),
        ]

        let result = try await provider.request(.batch(requests: calls)).map(as: [JSONRPCResponse<String>].self)
        return try decodeStakeDelegations(result)
    }

    public func getStakeBalance(for address: String) async throws -> AssetBalance? {
        let delegations = try await getStakeDelegations(address: address)
        let staked = delegations.filter { $0.state == .active }.map { $0.balanceValue }.reduce(0, +)
        let pending = delegations
            .filter { $0.state == .undelegating || $0.state == .awaitingWithdrawal }
            .map { $0.balanceValue }
            .reduce(0, +)

        return AssetBalance(
            assetId: Chain.smartChain.assetId,
            balance: Balance(
                staked: staked,
                pending: pending
            )
        )
    }

    func decodeStakeDelegations(_ result: [JSONRPCResponse<String>]) throws -> [DelegationBase] {
        guard
            result.count == 2,
            let data1 = Data(hexString: result[0].result),
            let data2 = Data(hexString: result[1].result)
        else {
            return []
        }

        let delegations = try stakeHub.decodeDelegationsResult(data: data1)
        let undelegations = try stakeHub.decodeUnelegationsResult(data: data2)

        return delegations + undelegations
    }


    private func getDelegationsCall(address: String, limit: UInt16) throws -> EthereumTarget {
        .call([
            "to": StakeHub.reader,
            "data": try stakeHub.encodeDelegationsCall(address: address, limit: limit),
        ])
    }

    private func getUndelegationsCall(address: String, limit: UInt16) throws -> EthereumTarget {
        .call([
            "to": StakeHub.reader,
            "data": try stakeHub.encodeUndelegationsCall(address: address, limit: limit),
        ])
    }
}
