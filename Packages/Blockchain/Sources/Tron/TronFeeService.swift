// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Foundation
import Primitives

struct TronFeeService: Sendable {
    private static let baseFee = BigInt(280_000)

    func nativeTransferFee(
        accountUsage: TronAccountUsage,
        parameters: [TronChainParameter],
        isNewAccount: Bool
    ) throws -> BigInt {
        let newAccountFee = try parameters.value(for: .getCreateAccountFee)
        let newAccountFeeInSmartContract = try parameters.value(for: .getCreateNewAccountFeeInSystemContract)

        let availableBandwidth = (accountUsage.freeNetLimit ?? 0) - (accountUsage.freeNetUsed ?? 0)
        let coinTransferFee = availableBandwidth >= 300 ? BigInt.zero : BigInt(Self.baseFee)

        return isNewAccount ? coinTransferFee + BigInt(newAccountFee + newAccountFeeInSmartContract) : coinTransferFee
    }

    func trc20TransferFee(
        accountUsage: TronAccountUsage,
        parameters: [TronChainParameter],
        gasLimit: BigInt,
        isNewAccount: Bool
    ) throws -> BigInt {
        let energyFee = try parameters.value(for: .getEnergyFee)
        let newAccountFeeInSmartContract = try parameters.value(for: .getCreateNewAccountFeeInSystemContract)

        let availableEnergy = BigInt(accountUsage.EnergyLimit ?? 0) - BigInt(accountUsage.EnergyUsed ?? 0)
        let energyShortfall = max(BigInt.zero, gasLimit.increase(byPercent: 20) - availableEnergy)
        let tokenTransferFee = BigInt(energyFee) * energyShortfall

        return isNewAccount ? tokenTransferFee + BigInt(newAccountFeeInSmartContract) : tokenTransferFee
    }

    func stakeFee(
        accountUsage: TronAccountUsage,
        type: StakeType,
        totalStaked: BigInt,
        inputValue: BigInt
    ) -> BigInt {
        let availableBandwidth = (accountUsage.freeNetLimit ?? 0) - (accountUsage.freeNetUsed ?? 0)
        switch type {
        case .stake:
            return availableBandwidth >= 580 ? BigInt.zero : BigInt(Self.baseFee * 2)
        case .unstake:
            if totalStaked > inputValue {
                return availableBandwidth >= 580 ? BigInt.zero : BigInt(Self.baseFee * 2)
            } else {
                return availableBandwidth >= 300 ? BigInt.zero : BigInt(Self.baseFee)
            }
        case .rewards, .withdraw, .redelegate:
            return availableBandwidth >= 300 ? BigInt.zero : BigInt(Self.baseFee)
        }
    }
}

extension Collection where Element == TronChainParameter {
    func value(for key: TronChainParameterKey) throws -> Int64 {
        guard let value = first(where: { $0.key == key.rawValue })?.value else {
            throw AnyError("Unknown Tron chain parameter key: \(key)")
        }
        return value
    }
}
