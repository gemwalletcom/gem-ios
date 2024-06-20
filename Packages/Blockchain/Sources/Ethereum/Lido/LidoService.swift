// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import Primitives
import SwiftHTTPClient
import BigInt
import Gemstone

// https://docs.lido.fi/deployed-contracts/
public struct LidoService {
    public let provider: Provider<EthereumProvider>


    public init(provider: Provider<EthereumProvider>) {
        self.provider = provider
    }

    public func getStakeDelegations(address: String) async throws -> [DelegationBase] {
        async let balanceCall = try getBalance(address: address)
        async let unstakeCall = try getUndelegations(address: address)
        let (balance, undelegations) = try await (balanceCall, unstakeCall)
        var delegations = [DelegationBase]()
        if !balance.balance.staked.isZero {
            delegations = [
                DelegationBase(
                    assetId: Chain.ethereum.assetId,
                    state: .active,
                    balance: balance.balance.staked.description,
                    shares: "",
                    rewards: "",
                    completionDate: nil,
                    delegationId: LidoContract.address,
                    validatorId: LidoContract.address
                )
            ]
        }
        return delegations + undelegations
    }

    public func getBalance(address: String) async throws -> AssetBalance {
        let params = [
            "to": LidoContract.address,
            "data": LidoContract.encodeBalanceOf(address: address).hexString.append0x
        ]
        let balance = try await provider
            .request(.call(params))
            .map(as: JSONRPCResponse<BigIntable>.self).result.value

        // stETH always keeps 0.000000000000000001 as zero value (gas optimization for EVM), mark 0 here
        let value = balance == 1 ? 0 : balance

        return AssetBalance(
            assetId: Chain.ethereum.assetId,
            balance: Balance(available: .zero, staked: value)
        )
    }

    public func getUndelegations(address: String) async throws -> [DelegationBase] {
        let ids = try await getWithdrawalRequestIds(address: address)
        let params = [
            "to": LidoContract.withdrawal,
            "data": try lidoEncodeWithdrawalStatuses(requestIds: ids).hexString.append0x
        ]
        let result = try await provider.request(.call(params)).mapResult(String.self)
        guard let data = Data(hexString: result) else {
            throw AnyError("failed to fetch withdrawal requests")
        }
        let statues = try lidoDecodeGetWithdrawalStatuses(result: data)
        var undelegations = [DelegationBase]()
        zip(ids, statues).forEach { (id, request) in
            if !request.isClaimed {
                undelegations.append(request.into(requestId: id))
            }
        }
        return undelegations
    }

    func getWithdrawalRequestIds(address: String) async throws -> [String] {
        let params = [
            "to": LidoContract.withdrawal,
            "data": try lidoEncodeWithdrawalRequestIds(owner: address).hexString.append0x
        ]

        let result = try await provider.request(.call(params)).mapResult(String.self)
        guard let data = Data(hexString: result) else {
            throw AnyError("failed to fetch withdrawal requests")
        }
        return try Gemstone.lidoDecodeWithdrawalRequestIds(result: data)
    }

    func getPermitNonce(address: String) async throws -> String {
        let params = [
            "to": LidoContract.address,
            "data": LidoContract.encodeNonce(address: address).hexString.append0x
        ]
        let result = try await provider.request(.call(params)).mapResult(String.self)
        guard let data = Data(hexString: result) else {
            throw AnyError("failed to fetch permit nonce")
        }
        return EthereumAbiValue.decodeUInt256(input: data)
    }
}

extension DelegationValidator {
    public static let lido = DelegationValidator(
        chain: .ethereum,
        id: LidoContract.address,
        name: "Lido",
        isActive: true,
        commision: 0.1,
        apr: 3.3
    )
}

extension LidoWithdrawalRequest {
    public func into(requestId: String) -> DelegationBase {

        let state: DelegationState = isFinalized ? .awaitingWithdrawal: .pending
        let validatorId = LidoContract.address
        let completionDate = Date(timeIntervalSince1970: Double(timestamp))

        return DelegationBase(
            assetId: Chain.ethereum.assetId,
            state: state,
            balance: amount,
            shares: shares,
            rewards: "0",
            completionDate: completionDate,
            delegationId: requestId,
            validatorId: validatorId
        )
    }
}
