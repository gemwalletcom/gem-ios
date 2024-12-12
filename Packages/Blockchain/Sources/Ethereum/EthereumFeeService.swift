// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import BigInt
import Primitives
import GemstonePrimitives
import Gemstone

extension EthereumService {
    public func getData(input: FeeInput) -> Data? {
        switch input.type {
        case .transfer(let asset):
            switch asset.id.type {
            case .native:
                return .none
            case .token:
                let function = EthereumAbiFunction(name: "transfer")
                function.addParamAddress(val: Data(hexString: input.destinationAddress.remove0x)!, isOutput: false)
                function.addParamUInt256(val: input.value.magnitude.serialize(), isOutput: false)
                return EthereumAbi.encode(fn: function)
            }
        case .swap(_, _, let type):
            switch type {
            case .approval(let spender, let allowance):
                let function = EthereumAbiFunction(name: "approve")
                function.addParamAddress(val: Data(hexString: spender.remove0x)!, isOutput: false)
                function.addParamUInt256(val: allowance.magnitude.serialize(), isOutput: false)
                return EthereumAbi.encode(fn: function)
            case .swap(_, let data):
                return Data(fromHex: data.data)
            }
        case .generic(_, _, let extra):
            return extra.data
        case .stake(_, let stakeType):
            switch input.chain {
            case .smartChain:
                return try? StakeHub().encodeStake(type: stakeType, amount: input.value)
            case .ethereum:
                if stakeType.validatorId != DelegationValidator.lido.id {
                    // refactor later to support everstake and others
                    fatalError()
                }
                // empty signature for gas estimation
                let signature = Data(repeating: 0, count: 65)
                return try? LidoContract.encodeStake(type: stakeType, sender: input.senderAddress, amount: input.value, signature: signature)
            default:
                fatalError()
            }
        }
    }
    public func getTo(input: FeeInput) -> String {
        switch input.type {
        case .transfer(let asset):
            switch asset.id.type {
            case .native:
                return input.destinationAddress
            case .token:
                return asset.tokenId!
            }
        case .swap:
            return input.destinationAddress
        case .generic:
            return input.destinationAddress
        case .stake:
            switch input.chain {
            case .smartChain:
                return StakeHub.address
            case .ethereum:
                return input.destinationAddress
            default:
                fatalError()
            }
        }
    }

    public func getValue(input: FeeInput) -> BigInt? {
        switch input.type {
        case .transfer(let asset):
            switch asset.id.type {
            case .native:
                return input.value
            case .token:
                return .none
            }
        case .swap(let asset, _, let type):
            switch type {
            case .approval:
                return .zero
            case .swap:
                switch asset.id.type {
                case .native:
                    return input.value
                case .token:
                    return .none
                }
            }
        case .generic:
            return input.value
        case .stake(_, let type):
            switch input.chain {
            case .smartChain,
                    .ethereum:
                switch type {
                case .stake:
                    return input.value
                case .unstake, .redelegate, .withdraw:
                    return .none
                case .rewards:
                    fatalError()
                }
            default:
                fatalError()
            }
        }
    }

    func getBasePriorityFees(
        blocks: Int,
        rewardsPercentiles: EvmHistoryRewardPercentiles,
        minPriorityFee: BigInt
    ) async throws -> (
        base: BigInt,
        priority: [FeePriority: BigInt]
    ) {
        let feeHistory = try await provider
            .request(.feeHistory(blocks: blocks, rewardPercentiles: rewardsPercentiles.all))
            .map(as: JSONRPCResponse<EthereumFeeHistory>.self).result

        guard
            let baseFeeHex = feeHistory.baseFeePerGas.last,
            let baseFeePerGas = try? BigInt.fromHex(baseFeeHex)
        else {
            throw AnyError("Unable to retrieve base fee from history")
        }
        let priorityFees = calculatePriorityFees(
            rewards: feeHistory.reward.toBigInts(),
            rewardsPercentiles: rewardsPercentiles,
            minPriorityFee: minPriorityFee
        )
        return (baseFeePerGas, priorityFees)
    }

    func calculatePriorityFees(
        rewards: [[BigInt]],
        rewardsPercentiles: EvmHistoryRewardPercentiles,
        minPriorityFee: BigInt
    ) -> [FeePriority: BigInt] {
        let percentileToPriority: [Int: FeePriority] = [
            Int(rewardsPercentiles.slow): .slow,
            Int(rewardsPercentiles.normal): .normal,
            Int(rewardsPercentiles.fast): .fast
        ]
        return FeePriority.allCases.reduce(into: [FeePriority: BigInt]()) { result, priority in
            guard let index = rewardsPercentiles.all.firstIndex(where: { percentileToPriority[$0] == priority }) else {
                result[priority] = minPriorityFee
                return
            }
            let fees = rewards.compactMap { $0[safe: index] }
            let average = fees.isEmpty ? minPriorityFee : max(minPriorityFee, fees.reduce(0, +) / BigInt(fees.count))
            result[priority] = average
        }
    }

    public func fee(input: FeeInput) async throws -> Fee {
        if chain.isOpStack {
            // gas oracle estimates for enveloped tx only
            return try await OptimismGasOracle(chain: chain, provider: provider).fee(input: input)
        }

        let data = getData(input: input)
        let to = getTo(input: input)
        let value = getValue(input: input)

        async let getGasLimit: BigInt = {
            if case .stake(_, let stakeType) = input.type {
                return try await EthereumStakeService(service: self)
                    .getGasLimit(
                        chain: chain,
                        type: stakeType,
                        stakeValue: input.value, // original value
                        from: input.senderAddress,
                        to: to,
                        value: value,
                        data: data
                    )
            }
            return try await self.getGasLimit(
                from: input.senderAddress,
                to: to,
                value: value?.hexString.append0x,
                data: data?.hexString.append0x
            )
        }()

        let (gasLimit) = try await (getGasLimit)
        let gasPriceType = input.gasPrice
        
        let priorityFee = {
            switch input.type {
            case .transfer(let asset):
                asset.type == .native && input.isMaxAmount ? gasPriceType.totalFee : gasPriceType.priorityFee
            case .generic, .swap, .stake:
                gasPriceType.priorityFee
            }
        }()
    
        return Fee(
            fee: input.gasPrice.totalFee * gasLimit,
            gasPriceType: .eip1559(
                gasPrice: input.gasPrice.totalFee,
                priorityFee: priorityFee
            ),
            gasLimit: gasLimit
        )
    }
}

extension EthereumService: ChainFeeRateFetchable {
    public func feeRates(type: TransferDataType) async throws -> [FeeRate] {
        let config = GemstoneConfig.shared.config(for: chain)
        let (baseFee, priorityFees) = try await getBasePriorityFees(
            blocks: Self.historyBlocks,
            rewardsPercentiles: config.rewardsPercentiles,
            minPriorityFee: config.minPriorityFee.asBigInt
        )
        let feeRates = FeePriority.allCases.compactMap { priority in
            priorityFees[priority].map {
                FeeRate(
                    priority: priority,
                    gasPriceType: .eip1559(gasPrice: baseFee, priorityFee: $0)
                )
            }
        }
        return feeRates
    }
}

// MARK: - Model extensions

extension EvmHistoryRewardPercentiles {
    var all: [Int] { [slow, normal, fast].map {Int($0)} }
}

extension Array where Element == [String] {
    func toBigInts() -> [[BigInt]] {
        map { values in
            values.compactMap { feeHex in
                try? BigInt.fromHex(feeHex)
            }
        }
    }
}
