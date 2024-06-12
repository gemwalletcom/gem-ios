// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import Primitives
import BigInt
import Gemstone

public struct LidoContract {
    public static let address = "0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84"    // stETH token
    public static let withdrawal = "0x889edC2eDab5f40e902b864aD4d7AdE8E412F9B1" // WithdrawalQueueERC721
    public static let withdrawLimit = 300_000 // one unstETH
    
    public static func encodeStake(type: StakeType, sender: String, amount: BigInt, signature: Data) throws -> Data {
        switch type {
        case .stake:
            return try Self.encodeSubmit()
        case .unstake:
            // sign ERC-2612 permit for stETH
            let deadline = Self.permitDeadline(date: .now)
            let permit = Erc2612Permit(value: amount.description, deadline: deadline, signature: signature)
            return try Self.encodeRequestWithdrawalsWithPermit(amount: amount, owner: sender, permit: permit)
        case .withdraw(let delegation):
            return try Self.encodeClaimWithdrawal(requestId: delegation.base.delegationId)
        case .rewards, .redelegate:
            fatalError()
        }
    }

    public static func encodeSubmit(referral: String = "") throws -> Data {
        try Gemstone.lidoEncodeSubmit(referral: referral)
    }

    public static func encodeBalanceOf(address: String) -> Data {
        let fn = EthereumAbiFunction(name: "balanceOf")
        let address = Data(hexString: address)
        fn.addParamAddress(val: address ?? Data(), isOutput: false)
        return EthereumAbi.encode(fn: fn)
    }

    public static func encodeNonce(address: String) -> Data {
        let fn = EthereumAbiFunction(name: "nonces")
        let address = Data(hexString: address)
        fn.addParamAddress(val: address ?? Data(), isOutput: false)
        return EthereumAbi.encode(fn: fn)
    }

    public static func encodeRequestWithdrawalsWithPermit(amount: BigInt, owner: String, permit: Erc2612Permit) throws -> Data {
        return try Gemstone.lidoEncodeRequestWithdrawals(
            amounts: [amount.description],
            owner: owner,
            permit: permit
        )
    }

    public static func encodeClaimWithdrawal(requestId: String) throws -> Data {
        guard
            let part = requestId.split(separator: "-").last
        else {
            throw AnyError("Invalid request id: \(requestId)")
        }
        return try Gemstone.lidoEncodeClaimWithdrawal(requestId: String(part))
    }

    public static func permitDeadline(date: Date) -> UInt64 {
        let date = Calendar(identifier: .gregorian).startOfDay(for: date)
        let timestamp = date.addingTimeInterval(4 * 24 * 60 * 60)
        return UInt64(timestamp.timeIntervalSince1970)
    }
}
