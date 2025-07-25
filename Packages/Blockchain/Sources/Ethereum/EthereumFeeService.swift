// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Foundation
import struct Gemstone.EvmChainConfig
import struct Gemstone.EvmHistoryRewardPercentiles
import GemstonePrimitives
import Primitives
import WalletCore

extension EthereumService {
    public func getData(input: FeeInput) throws -> Data? {
        switch input.type {
        case let .transfer(asset, _):
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
        case .swap(_, _, let data):
            switch data.approval {
            case .some(let approvalData):
                return EthereumAbi.approve(spender: try Data.from(hex: approvalData.spender), value: .MAX_256)
            case .none:
                return Data(fromHex: data.data.data)
            }
        case .tokenApprove(_, let data):
            return EthereumAbi.approve(spender: try Data.from(hex: data.spender), value: .MAX_256)
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
        case let .transfer(asset, _):
            switch asset.id.type {
            case .native:
                return input.destinationAddress
            case .token:
                return try asset.getTokenId()
            }
        case .transferNft(let asset):
            return try asset.getContractAddress()
        case .swap(_, _, let data):
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

    func getValue(input: FeeInput) -> BigInt? {
        switch input.type {
        case let .transfer(asset, _):
            switch asset.id.type {
            case .native: return input.value
            case .token: return .none
            }
        case .transferNft: return .zero
        case .swap(_, _, let data):
            switch data.approval {
            case .some: return .zero
            case .none: return BigInt(stringLiteral: data.data.value)
            }
        case .tokenApprove: return .zero
        case .generic: return input.value
        case .stake(_, let type):
            switch input.chain {
            case .smartChain,
                 .ethereum:
                switch type {
                case .stake: return input.value
                case .unstake, .redelegate, .withdraw: return .none
                case .rewards:
                    fatalError()
                }
            default: fatalError()
            }
        case .account: fatalError()
        }
    }
    
    // Special case for sending two transactions approve + swap (calculating total gas limit fee)
    public func extraFeeGasLimit(input: FeeInput) throws -> BigInt {
        switch input.type {
        case .swap(_, _, let data):
            switch data.approval {
            case .some: return try data.data.gasLimitBigInt()
            case .none: return .zero
            }
        default: return .zero
        }
    }
    
    internal static func getPriorityFeeByType(_ type: TransferDataType, isMaxAmount: Bool, gasPriceType: GasPriceType) -> BigInt {
        return switch type {
        case let .transfer(asset, _):
            asset.type == .native && isMaxAmount ? gasPriceType.totalFee : gasPriceType.priorityFee
        case .transferNft, .generic, .swap, .tokenApprove, .stake:
            gasPriceType.priorityFee
        case .account: fatalError()
        }
    }
    
    public func gasLimit(input: FeeInput) async throws -> BigInt {
        if let gasLimit = input.gasLimit {
            return gasLimit
        }
        return try await getGasLimit(
            from: input.senderAddress,
            to: try getTo(input: input),
            value: getValue(input: input)?.hexString.append0x,
            data: try getData(input: input)?.hexString.append0x
        )
    }
    
    public func fee(input: FeeInput) async throws -> Fee {
        if chain.isOpStack {
            // gas oracle estimates for enveloped tx only
            return try await OptimismGasOracle(chain: chain, provider: provider).fee(input: input)
        }
        
        let extraFeeGasLimit = try extraFeeGasLimit(input: input)
        let gasLimit = try await gasLimit(input: input)
        let priorityFee = Self.getPriorityFeeByType(input.type, isMaxAmount: input.isMaxAmount, gasPriceType: input.gasPrice)

        return Fee(
            fee: input.gasPrice.totalFee * (gasLimit + extraFeeGasLimit),
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
        let (baseFee, priorityFees) = try await getBasePriorityFees(config: config)
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

    private func getBasePriorityFees(config: EvmChainConfig) async throws -> (base: BigInt, priority: [FeePriority: BigInt]) {
        let feeHistory = try await provider
            .request(
                .feeHistory(
                    blocks: Int(config.feeHistoryBlocks),
                    rewardPercentiles: config.rewardsPercentiles.all,
                    blockParameter: .pending
                )
            )
            .map(as: JSONRPCResponse<EthereumFeeHistory>.self).result

        return try calculator.basePriorityFees(chain: chain, feeHistory: feeHistory)
    }
}

// MARK: - Model extensions

extension EvmHistoryRewardPercentiles {
    var all: [Int] { [slow, normal, fast].map { Int($0) } }
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
