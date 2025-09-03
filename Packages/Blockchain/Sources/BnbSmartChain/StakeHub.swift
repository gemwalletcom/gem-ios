// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt
import func Gemstone.bscEncodeValidatorsCall
import func Gemstone.bscDecodeValidatorsReturn
import func Gemstone.bscEncodeDelegationsCall
import func Gemstone.bscDecodeDelegationsReturn
import func Gemstone.bscEncodeUndelegationsCall
import func Gemstone.bscDecodeUndelegationsReturn
import func Gemstone.bscEncodeDelegateCall
import func Gemstone.bscEncodeUndelegateCall
import func Gemstone.bscEncodeRedelegateCall
import func Gemstone.bscEncodeClaimCall
import struct Gemstone.BscValidator
import struct Gemstone.BscDelegation
import enum Gemstone.BscDelegationStatus
import Primitives

// https://github.com/bnb-chain/bsc-genesis-contract/blob/v1.2.2/abi/stakehub.abi
// https://github.com/bnb-chain/bsc-genesis-contract/blob/v1.2.2/contracts/BC_fusion/StakeHub.sol#L855
// https://github.com/gemwalletcom/contracts/blob/0.1.1/bsc/hub_reader/src/HubReader.sol
public struct StakeHub: Sendable {
    public static let address = "0x0000000000000000000000000000000000002002"
    public static let reader = "0x830295c0abe7358f7e24bc38408095621474280b"

    public init() {}

    public func encodeStake(type: StakeType, amount: BigInt) throws -> Data {
        switch type {
        case .stake(let validator):
            return try encodeDelegateCall(validator: validator.id, delegateVote: false)
        case .unstake(let delegation):
            let amountShare = amount * delegation.base.sharesValue / delegation.base.balanceValue
            return try encodeUndelegateCall(validator: delegation.validator.id, shares: amountShare)
        case .redelegate(let data):
            let amountShare = amount * data.delegation.base.sharesValue / data.delegation.base.balanceValue
            return try encodeRedelegateCall(shares: amountShare, fromValidator: data.delegation.base.validatorId, toValidator: data.toValidator.id, delegateVote: false)
        case .withdraw(let delegation):
            return try encodeClaim(validator: delegation.validator.id, requestNumber: 0) // 0 means all
        case .rewards:
            fatalError()
        }
    }

    public func encodeDelegationsCall(address: String, limit: UInt16) throws -> String {
        return try bscEncodeDelegationsCall(delegator: address, offset: 0, limit: limit).hexString.append0x
    }

    public func encodeUndelegationsCall(address: String, limit: UInt16) throws -> String {
        return try bscEncodeUndelegationsCall(delegator: address, offset: 0, limit: limit).hexString.append0x
    }

    public func encodeDelegateCall(validator: String, delegateVote: Bool) throws -> Data {
        return try bscEncodeDelegateCall(operatorAddress: validator, delegateVotePower: delegateVote)
    }

    public func encodeUndelegateCall(validator: String, shares: BigInt) throws -> Data {
        return try bscEncodeUndelegateCall(operatorAddress: validator, shares: shares.description)
    }

    public func encodeRedelegateCall(shares: BigInt, fromValidator: String, toValidator: String, delegateVote: Bool) throws -> Data {
        return try bscEncodeRedelegateCall(
            srcValidator: fromValidator,
            dstValidator: toValidator, 
            shares: shares.description,
            delegateVotePower: delegateVote
        )
    }

    public func encodeClaim(validator: String, requestNumber: UInt64) throws -> Data {
        return try bscEncodeClaimCall(operatorAddress: validator, requestNumber: requestNumber)
    }
}
