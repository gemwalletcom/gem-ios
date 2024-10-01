// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import WalletCorePrimitives
import Primitives
import Blockchain
import Keystore

// https://github.com/trustwallet/wallet-core/blob/master/swift/Tests/Blockchains/THORChainTests.swift#L27
public struct CosmosSigner: Signable {

    public func signTransfer(input: SignerInput, privateKey: Data) throws -> String {
        let chain = try CosmosChain.from(string: input.asset.chain.rawValue)
        let message = getTransferMessage(input: input, chain: chain, denom: chain.denom.rawValue)
        return try sign(input: input, messages: [message], chain: chain, privateKey: privateKey)
    }
    
    public func signTokenTransfer(input: SignerInput, privateKey: Data) throws -> String {
        let chain = try CosmosChain.from(string: input.asset.chain.rawValue)
        let denom = try input.asset.getTokenId()
        let message = getTransferMessage(input: input, chain: chain, denom: denom)
        return try sign(input: input, messages: [message], chain: chain, privateKey: privateKey)
    }
    
    private func sign(input: SignerInput, messages: [CosmosMessage], chain: CosmosChain, privateKey: Data) throws -> String {
        let fee = CosmosFee.with {
            $0.gas = UInt64(messages.count * input.fee.gasLimit.int)
            $0.amounts = [CosmosAmount.with {
                $0.amount = (input.fee.fee - input.fee.optionsFee).description
                $0.denom = chain.denom.rawValue
            }]
        }
        
        let signerInput = CosmosSigningInput.with {
            $0.mode = .sync
            $0.accountNumber = UInt64(input.accountNumber)
            $0.chainID = input.chainId
            $0.memo = input.memo.valueOrEmpty
            $0.sequence = UInt64(input.sequence)
            $0.messages = messages
            $0.fee = fee
            $0.privateKey = privateKey
            $0.signingMode = .protobuf
        }
        
        let output: CosmosSigningOutput = AnySigner.sign(input: signerInput, coin: input.coinType)
        
        if !output.errorMessage.isEmpty {
            throw AnyError(output.errorMessage)
        }
        
        return output.serialized
    }
    
    public func signData(input: Primitives.SignerInput, privateKey: Data) throws -> String {
        fatalError()
    }
    
    public func swap(input: SignerInput, privateKey: Data) throws -> String {
        fatalError()
    }
    
    public func signStake(input: SignerInput, privateKey: Data) throws -> String {
        guard case .stake(_, let type) = input.type else {
            throw AnyError("invalid type")
        }
        let messages: [CosmosMessage]
        let chain = try CosmosChain.from(string: input.asset.chain.rawValue)
        let denom = chain.denom.rawValue
        switch type {
        case .stake(let validator):
            let amount = getAmount(input: input, denom: denom)
            messages = [
                getStakeMessage(delegatorAddress: input.senderAddress, validatorAddress: validator.id, amount: amount)
            ]
        case .unstake(let delegation):
            let amount = getAmount(input: input, denom: denom)
            messages = [
                getUnstakeMessage(delegatorAddress: input.senderAddress, validatorAddress: delegation.validator.id, amount: amount)
            ]
        case .redelegate(let delegation, let toValidator):
            let amount = getAmount(input: input, denom: denom)
            messages = [
                getRedelegateMessage(
                    delegatorAddress: input.senderAddress,
                    validatorSourceAddress: delegation.validator.id,
                    validatorDestinationAddress: toValidator.id,
                    amount: amount
                )
            ]
        case .rewards(let validators):
            messages = getRewardMessage(delegatorAddress: input.senderAddress, validators: validators)
        case .withdraw:
            fatalError()
        }
        
        return try sign(input: input, messages: messages, chain: chain, privateKey: privateKey)
    }
    
    func getUnstakeMessage(delegatorAddress: String, validatorAddress: String, amount: CosmosAmount) -> CosmosMessage {
        .with {
            $0.unstakeMessage = .with {
                $0.amount = amount
                $0.delegatorAddress = delegatorAddress
                $0.validatorAddress = validatorAddress
            }
        }
    }
    
    func getRedelegateMessage(delegatorAddress: String, validatorSourceAddress: String, validatorDestinationAddress: String, amount: CosmosAmount) -> CosmosMessage {
        .with {
            $0.restakeMessage = .with {
                $0.amount = amount
                $0.delegatorAddress = delegatorAddress
                $0.validatorSrcAddress = validatorSourceAddress
                $0.validatorDstAddress = validatorDestinationAddress
            }
        }
    }
    
    func getStakeMessage(delegatorAddress: String, validatorAddress: String, amount: CosmosAmount) -> CosmosMessage {
        .with {
            $0.stakeMessage = .with {
                $0.amount = amount
                $0.delegatorAddress = delegatorAddress
                $0.validatorAddress = validatorAddress
            }
        }
    }
    
    func getRewardMessage(delegatorAddress: String, validators: [DelegationValidator]) -> [CosmosMessage] {
        return validators.map { validator in
            .with {
                $0.withdrawStakeRewardMessage = .with {
                    $0.delegatorAddress = delegatorAddress
                    $0.validatorAddress = validator.id
                }
            }
        }
    }
    
    func getAmount(input: SignerInput, denom: String) -> CosmosAmount {
        return CosmosAmount.with {
            $0.amount = input.value.description
            $0.denom = denom
        }
    }
    
    func getTransferMessage(input: SignerInput, chain: CosmosChain, denom: String) -> CosmosMessage {
        let amounts = [getAmount(input: input, denom: denom)]
        
        switch chain {
        case .cosmos,
            .osmosis,
            .celestia,
            .injective,
            .sei,
            .noble:
            return CosmosMessage.with {
                $0.sendCoinsMessage = CosmosMessage.Send.with {
                    $0.fromAddress = input.senderAddress
                    $0.toAddress = input.destinationAddress
                    $0.amounts = amounts
                }
            }
        case .thorchain:
            return CosmosMessage.with {
                $0.thorchainSendMessage = CosmosMessage.THORChainSend.with {
                    $0.fromAddress = AnyAddress(string: input.senderAddress, coin: chain.chain.coinType)!.data
                    $0.toAddress = AnyAddress(string: input.destinationAddress, coin: chain.chain.coinType)!.data
                    $0.amounts = amounts
                }
            }
        }
    }
}
