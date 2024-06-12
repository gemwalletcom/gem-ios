// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import BigInt
import Primitives

extension EthereumService: ChainFeeCalculateable {

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
            case .swap(let data):
                return data.hexData
            }
        case .generic(_, _, let extra):
            return extra.data
        case .stake(_, let stakeType):
            switch input.chain {
            case .smartChain:
                return try? StakeHub().encodeStake(type: stakeType, amount: input.value)
            case .ethereum:
                do {
                    let signature = Data(repeating: 0, count: 65)
                    return try LidoContract.encodeStake(type: stakeType, sender: input.senderAddress, amount: input.value, signature: signature)
                } catch let error {
                    print(error)
                    return nil
                }
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
    
    public func fee(input: FeeInput) async throws -> Fee {
        
        if chain.isOpStack {
            // gas oracle estimates for enveloped tx only
            return try await OptimismGasOracle(chain: chain, provider: provider).fee(input: input)
        }
        
        let data = getData(input: input)
        let to = getTo(input: input)
        let value = getValue(input: input)
        
        let gasLimit: BigInt
        if case .stake(_, let stakeType) = input.type {
            gasLimit = try await EthereumStakeService(service: self)
                .getGasLimit(
                    chain: chain,
                    type: stakeType,
                    stakeValue: input.value, // original value
                    from: input.senderAddress,
                    to: to,
                    value: value,
                    data: data
                )
        } else {
            gasLimit = try await getGasLimit(
                from: input.senderAddress,
                to: to,
                value: value?.hexString.append0x,
                data: data?.hexString.append0x
            )
        }
        
        async let getGasPrice = getBasePriorityFee(rewardPercentiles: Self.rewardPercentiles)
        let basePriorityFee = try await getGasPrice

        let gasPrice = basePriorityFee.baseFee + basePriorityFee.priorityFee
        let minerFee = {
            switch input.type {
            case .transfer(let asset):
                return (asset.type == .native && input.isMaxAmount) ? gasPrice : basePriorityFee.priorityFee
            case .generic, .swap, .stake:
                return basePriorityFee.priorityFee
            }
        }()
        
        return Fee(
            fee: gasPrice * gasLimit,
            gasPriceType: .eip1559(
                gasPrice: gasPrice,
                minerFee: minerFee
            ),
            gasLimit: gasLimit
        )
    }
}
