// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt
import Gemstone
import Primitives

// https://github.com/bnb-chain/bsc-genesis-contract/blob/v1.2.2/abi/stakehub.abi
// https://github.com/bnb-chain/bsc-genesis-contract/blob/v1.2.2/contracts/BC_fusion/StakeHub.sol#L855
// https://github.com/gemwalletcom/contracts/blob/0.1.1/bsc/hub_reader/src/HubReader.sol
public struct StakeHub {
    public static let address = "0x0000000000000000000000000000000000002002"
    public static let reader = "0x830295c0abe7358f7e24bc38408095621474280b"

    public init() {}

    public func encodeStake(type: StakeType, amount: BigInt) throws -> Data {
        switch type {
        case .stake(let validator):
            return try encodeDelegateCall(validator: validator.id, delegateVote: false)
        case .unstake(delegation: let delegation):
            let amountShare = amount * delegation.base.sharesValue / delegation.base.balanceValue
            return try encodeUndelegateCall(validator: delegation.validator.id, shares: amountShare)
        case .redelegate(delegation: let delegation, toValidator: let toValidator):
            let amountShare = amount * delegation.base.sharesValue / delegation.base.balanceValue
            return try encodeRedelegateCall(shares: amountShare, fromValidator: delegation.base.validatorId, toValidator: toValidator.id, delegateVote: false)
        case .withdraw(delegation: let delegation):
            return try encodeClaim(validator: delegation.validator.id, requestNumber: 0) // 0 means all
        case .rewards:
            fatalError()
        }
    }

    public func encodeMaxElectedValidators() -> String {
        // cast calldata "maxElectedValidators()"
        return "0xc473318f"
    }

    public func encodeValidatorsCall(offset: UInt16, limit: UInt16) -> String {
        return Gemstone.bscEncodeValidatorsCall(offset: offset, limit: limit).hexString.append0x
    }

    public func decodeValidatorsReturn(data: Data) throws -> [DelegationValidator] {
        return try Gemstone.bscDecodeValidatorsReturn(result: data).map { $0.into() }
    }

    public func encodeDelegationsCall(address: String, limit: UInt16) throws -> String {
        return try Gemstone.bscEncodeDelegationsCall(delegator: address, offset: 0, limit: limit).hexString.append0x
    }

    public func decodeDelegationsResult(data: Data) throws -> [DelegationBase] {
        return try Gemstone.bscDecodeDelegationsReturn(result: data).map { $0.into() }
    }

    public func encodeUndelegationsCall(address: String, limit: UInt16) throws -> String {
        return try Gemstone.bscEncodeUndelegationsCall(delegator: address, offset: 0, limit: limit).hexString.append0x
    }

    public func decodeUnelegationsResult(data: Data) throws -> [DelegationBase] {
        return try Gemstone.bscDecodeUndelegationsReturn(result: data).map { $0.into() }
    }

    // Actions
    public func encodeDelegateCall(validator: String, delegateVote: Bool) throws -> Data {
        return try Gemstone.bscEncodeDelegateCall(operatorAddress: validator, delegateVotePower: delegateVote)
    }

    public func encodeUndelegateCall(validator: String, shares: BigInt) throws -> Data {
        return try Gemstone.bscEncodeUndelegateCall(operatorAddress: validator, shares: shares.description)
    }


    public func encodeRedelegateCall(shares: BigInt, fromValidator: String, toValidator: String, delegateVote: Bool) throws -> Data {
        return try Gemstone.bscEncodeRedelegateCall(
            srcValidator: fromValidator,
            dstValidator: toValidator, 
            shares: shares.description,
            delegateVotePower: delegateVote
        )
    }

    public func encodeClaim(validator: String, requestNumber: UInt64) throws -> Data {
        return try Gemstone.bscEncodeClaimCall(operatorAddress: validator, requestNumber: requestNumber)
    }
}

public extension BscValidator {
    func into() -> DelegationValidator {
        return DelegationValidator(
            chain: .smartChain,
            id: operatorAddress,
            name: moniker,
            isActive: !jailed,
            commision: Double(commission) / 100,
            apr: Double(apy) / 100
        )
    }
}

public extension BscDelegation {
    func into() -> DelegationBase {
        let completionDate: Date? = {
            switch status {
            case .active:
                return nil
            case .undelegating:
                guard let unlock = unlockTime else {
                    return nil
                }
                return Date(timeIntervalSince1970: Double(unlock))
            }
        }()

        let state: DelegationState = {
            switch status {
            case .active: 
                return .active
            case .undelegating:
                guard let date = completionDate else {
                    return .undelegating
                }
                guard date.distance(to: Date()) >= 0 else {
                    return .undelegating
                }
                return .awaitingWithdrawal
            }
        }()

        let delegationId: String = switch status {
            case .active: .empty
            case .undelegating: "\(validatorAddress)-\(unlockTime ?? 0)"
        }

        return DelegationBase(
            assetId: Chain.smartChain.assetId,
            state: state,
            balance: amount,
            shares: shares,
            rewards: "0",
            completionDate: completionDate,
            delegationId: delegationId,
            validatorId: validatorAddress
        )
    }
}
