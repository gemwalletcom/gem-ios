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
    ) throws -> Fee {
        let newAccountFee = try parameters.value(for: .getCreateAccountFee)
        let newAccountFeeInSmartContract = try parameters.value(for: .getCreateNewAccountFeeInSystemContract)

        let availableBandwidth = (accountUsage.freeNetLimit ?? 0) - (accountUsage.freeNetUsed ?? 0)
        let coinTransferFee = availableBandwidth >= 300 ? BigInt.zero : BigInt(Self.baseFee)

        return .fee(value: isNewAccount ? coinTransferFee + BigInt(newAccountFee + newAccountFeeInSmartContract) : coinTransferFee)
    }

    func trc20TransferFee(
        accountUsage: TronAccountUsage,
        parameters: [TronChainParameter],
        gasLimit: BigInt,
        isNewAccount: Bool
    ) throws -> Fee {
        let energyFee = try parameters.value(for: .getEnergyFee)
        let newAccountFeeInSmartContract = try parameters.value(for: .getCreateNewAccountFeeInSystemContract)

        let availableEnergy = BigInt(accountUsage.EnergyLimit ?? 0) - BigInt(accountUsage.EnergyUsed ?? 0)
        let energyShortfall = max(BigInt.zero, gasLimit.increase(byPercent: 20) - availableEnergy)
        let tokenTransferFee = BigInt(energyFee) * energyShortfall

        return .fee(value: isNewAccount ? tokenTransferFee + BigInt(newAccountFeeInSmartContract) : tokenTransferFee)
    }

    func stakeFee(
        accountUsage: TronAccountUsage,
        type: StakeType,
        totalStaked: BigInt,
        inputValue: BigInt
    ) -> Fee {
        let availableBandwidth = (accountUsage.freeNetLimit ?? 0) - (accountUsage.freeNetUsed ?? 0)
        switch type {
        case .stake:
            return .fee(value: availableBandwidth >= 580 ? BigInt.zero : BigInt(Self.baseFee * 2))
        case .unstake:
            if totalStaked > inputValue {
                return .fee(value: availableBandwidth >= 580 ? BigInt.zero : BigInt(Self.baseFee * 2))
            } else {
                return .fee(value: availableBandwidth >= 300 ? BigInt.zero : BigInt(Self.baseFee))
            }
        case .rewards, .withdraw, .redelegate:
            return .fee(value: availableBandwidth >= 300 ? BigInt.zero : BigInt(Self.baseFee))
        }
    }
    
    func swapFee(
        estimatedEnergy: BigInt,
        accountEnergy: UInt64,
        parameters: [TronChainParameter]
    ) throws -> Fee {
        let energyFee = try parameters.value(for: .getEnergyFee)
        let gasLimit = (estimatedEnergy - BigInt(accountEnergy)).increase(byPercent: 10)
        let gasPrice = BigInt(energyFee)

        return Fee(
            fee: gasLimit * gasPrice,
            gasPriceType: .regular(gasPrice: gasPrice),
            gasLimit: gasLimit
        )
    }
    
    func accountEnergy(usage: TronAccountUsage) -> UInt64 {
        guard
            let energyLimit = usage.EnergyLimit,
            let energyUsed = usage.EnergyUsed
        else {
            return .zero
        }
        return max(UInt64(energyLimit - energyUsed), 0)
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

private extension Fee {
    static func fee(value: BigInt) -> Fee {
        Fee(
            fee: value,
            gasPriceType: .regular(gasPrice: value),
            gasLimit: 1
        )
    }
}
