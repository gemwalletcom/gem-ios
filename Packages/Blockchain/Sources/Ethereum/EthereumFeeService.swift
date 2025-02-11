// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import BigInt
import Primitives
import GemstonePrimitives
import Gemstone

extension EthereumService {
    public func getData(input: FeeInput) throws -> Data? {
        switch input.type {
        case .transfer(let asset):
            switch asset.id.type {
            case .native:
                return .none
            case .token:
                let function = EthereumAbiFunction(name: "transfer")
                function.addParamAddress(val: try Data.from(hex: input.destinationAddress), isOutput: false)
                function.addParamUInt256(val: input.value.magnitude.serialize(), isOutput: false)
                return EthereumAbi.encode(fn: function)
            }
        case .transferNft(let asset):
            switch asset.tokenType {
            case .erc721:
                let function = EthereumAbiFunction(name: "safeTransferFrom")
                function.addParamAddress(val: try Data.from(hex: input.senderAddress), isOutput: false)
                function.addParamAddress(val: try Data.from(hex: input.destinationAddress), isOutput: false)
                function.addParamUInt256(val: BigInt(stringLiteral: asset.tokenId).magnitude.serialize(), isOutput: false)
                return EthereumAbi.encode(fn: function)
            case .erc1155:
                let function = EthereumAbiFunction(name: "safeTransferFrom")
                function.addParamAddress(val: try Data.from(hex: input.senderAddress), isOutput: false)
                function.addParamAddress(val: try Data.from(hex: input.destinationAddress), isOutput: false)
                function.addParamUInt256(val: BigInt(stringLiteral: asset.tokenId).magnitude.serialize(), isOutput: false)
                function.addParamUInt256(val: BigInt(1).magnitude.serialize(), isOutput: false)
                function.addParamBytes(val: Data(), isOutput: false)
                return EthereumAbi.encode(fn: function)
            case .spl, .jetton:
                fatalError()
            }
        case .swap(_, _, _, let data):
            switch data.approval {
            case .some(let approvalData):
                let function = EthereumAbiFunction(name: "approve")
                function.addParamAddress(val: try Data.from(hex: approvalData.spender), isOutput: false)
                function.addParamUInt256(val: BigInt.MAX_256.magnitude.serialize(), isOutput: false)
                return EthereumAbi.encode(fn: function)
            case .none:
                return Data(fromHex: data.data)
            }
        case .tokenApprove(_, let data):
            let function = EthereumAbiFunction(name: "approve")
            function.addParamAddress(val: try Data.from(hex: data.spender), isOutput: false)
            function.addParamUInt256(val: BigInt.MAX_256.magnitude.serialize(), isOutput: false)
            return EthereumAbi.encode(fn: function)
        case .generic(_, _, let extra):
            return extra.data
        case .stake(_, let stakeType):
            switch input.chain {
            case .smartChain:
                return try? StakeHub().encodeStake(type: stakeType, amount: input.value)
            default:
                fatalError()
            }
        case .account: fatalError()
        }
    }

    public func getTo(input: FeeInput) throws -> String {
        switch input.type {
        case .transfer(let asset):
            switch asset.id.type {
            case .native:
                return input.destinationAddress
            case .token:
                return try asset.getTokenId()
            }
        case .transferNft(let asset):
            return try asset.getContractAddress()
        case .swap(_, _, _, let data):
            switch data.approval {
            case .some(let approvalData): return approvalData.token
            case .none: return input.destinationAddress
            }
        case .tokenApprove(_, let data):
            return data.token
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
        case .account: fatalError()
        }
    }

    public func getValue(input: FeeInput) -> BigInt? {
        switch input.type {
        case .transfer(let asset):
            switch asset.id.type {
            case .native: input.value
            case .token: .none
            }
        case .transferNft: .zero
        case .swap(_, _, _, let data):
            switch data.approval {
            case .some: .zero
            case .none: BigInt(stringLiteral: data.value)
            }
        case .tokenApprove: .zero
        case .generic: input.value
        case .stake(_, let type):
            switch input.chain {
            case .smartChain,
                    .ethereum:
                switch type {
                case .stake: input.value
                case .unstake, .redelegate, .withdraw: .none
                case .rewards:
                    fatalError()
                }
            default: fatalError()
            }
        case .account: fatalError()
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

    public func limit() async throws -> BigInt {
        BigInt(450_000)
    }
    
    public func fee(input: FeeInput) async throws -> Fee {
        if chain.isOpStack {
            // gas oracle estimates for enveloped tx only
            return try await OptimismGasOracle(chain: chain, provider: provider).fee(input: input)
        }

        let data = try getData(input: input)
        let to = try getTo(input: input)
        let value = getValue(input: input)

        let gasLimit = try await self.getGasLimit(
            from: input.senderAddress,
            to: to,
            value: value?.hexString.append0x,
            data: data?.hexString.append0x
        )
        
        let gasPriceType = input.gasPrice
        
        let priorityFee = {
            switch input.type {
            case .transfer(let asset):
                asset.type == .native && input.isMaxAmount ? gasPriceType.totalFee : gasPriceType.priorityFee
            case .transferNft, .generic, .swap, .tokenApprove, .stake:
                gasPriceType.priorityFee
            case .account: fatalError()
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
