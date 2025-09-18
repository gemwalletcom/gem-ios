// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import BigInt
import Keystore
import Primitives
import GemstonePrimitives

public class EthereumSigner: Signable {

    public func signTransfer(input: SignerInput, privateKey: Data) throws -> String {
        let base = try buildBaseInput(
            input: input,
            transaction: .with {
                $0.transfer = EthereumTransaction.Transfer.with {
                    $0.amount = input.value.magnitude.serialize()
                }
            },
            toAddress: input.destinationAddress,
            privateKey: privateKey
        )
        return try sign(coinType: input.coinType, input: base)
    }
    
    public func signTokenTransfer(input: SignerInput, privateKey: Data) throws -> String {
        let base = try buildBaseInput(
            input: input,
            transaction: .with {
                $0.erc20Transfer = EthereumTransaction.ERC20Transfer.with {
                    $0.to = input.destinationAddress
                    $0.amount = input.value.magnitude.serialize()
                }
            },
            toAddress: try input.asset.getTokenId(),
            privateKey: privateKey
        )
        return try sign(coinType: input.coinType, input: base)
    }
    
    public func signNftTransfer(input: SignerInput, privateKey: Data) throws -> String {
        guard case .transferNft(let asset) = input.type else {
            fatalError()
        }
        let transaction: EthereumTransaction = switch asset.tokenType {
        case .erc721: EthereumTransaction.with {
            $0.erc721Transfer = .with {
                $0.from = input.senderAddress
                $0.to = input.destinationAddress
                $0.tokenID = BigInt(stringLiteral: asset.tokenId).magnitude.serialize()
            }
        }
        case .erc1155: EthereumTransaction.with {
            $0.erc1155Transfer = .with {
                $0.from = input.senderAddress
                $0.to = input.destinationAddress
                $0.tokenID = BigInt(stringLiteral: asset.tokenId).magnitude.serialize()
                $0.value = BigInt(1).magnitude.serialize()
            }
        }
        case .jetton, .spl: fatalError()
        }
        
        let base = try buildBaseInput(
            input: input,
            transaction: transaction,
            toAddress: try asset.getContractAddress(),
            privateKey: privateKey
        )
        return try sign(coinType: input.coinType, input: base)
    }
    
    internal func buildBaseInputCustom(
        input: SignerInput,
        transaction: EthereumTransaction,
        toAddress: String,
        nonce: BigInt,
        gasLimit: BigInt,
        privateKey: Data
    ) throws -> EthereumSigningInput {
        guard case let .eip1559(gasPrice,priorityFee) = input.fee.gasPriceType else {
            throw AnyError("no longer supported")
        }
        return try EthereumSigningInput.with {
            $0.txMode = .enveloped
            $0.maxFeePerGas = gasPrice.magnitude.serialize()
            $0.maxInclusionFeePerGas = priorityFee.magnitude.serialize()
            $0.gasLimit = gasLimit.magnitude.serialize()
            $0.chainID = BigInt(stringLiteral: try input.metadata.getChainId()).magnitude.serialize()
            $0.nonce = nonce.magnitude.serialize()
            $0.transaction = transaction
            $0.toAddress = toAddress
            $0.privateKey = privateKey
        }
    }
    
    internal func buildBaseInput(
        input: SignerInput,
        transaction: EthereumTransaction,
        toAddress: String,
        privateKey: Data
    ) throws -> EthereumSigningInput {
        try buildBaseInputCustom(
            input: input,
            transaction: transaction,
            toAddress: toAddress,
            nonce: BigInt(try input.metadata.getSequence()),
            gasLimit: input.fee.gasLimit,
            privateKey: privateKey
        )
    }
    
    // https://github.com/trustwallet/wallet-core/blob/master/swift/Tests/Blockchains/EthereumTests.swift
    internal func sign(coinType: CoinType, input: EthereumSigningInput) throws -> String {
        let output: EthereumSigningOutput = AnySigner.sign(input: input, coin: coinType)
        guard output.error == .ok else {
            throw AnyError("Failed to sign Ethereum tx: " + String(reflecting: output.error))
        }
        return output.encoded.hexString
    }
    
    public func signData(input: Primitives.SignerInput, privateKey: Data) throws -> String {
        guard case .generic(_, _, let extra) = input.type else {
            fatalError()
        }
        let base = try buildBaseInput(
            input: input,
            transaction: .with {
                $0.contractGeneric = EthereumTransaction.ContractGeneric.with {
                    $0.amount = input.value.magnitude.serialize()
                    $0.data = extra.data ?? Data()
                }
            },
            toAddress: input.destinationAddress,
            privateKey: privateKey
        )
        return try sign(coinType: input.coinType, input: base)
    }
    
    public func signSwap(input: SignerInput, privateKey: Data) throws -> [String] {
        let swapData = try input.type.swap().data.data
        switch swapData.approval {
        case .some(let approvalData):
            return [
                try sign(coinType: input.coinType, input: buildBaseInput(
                    input: input,
                    transaction: .with {
                        $0.erc20Approve = EthereumTransaction.ERC20Approve.with {
                            $0.spender = approvalData.spender
                            $0.amount = BigInt.MAX_256.magnitude.serialize()
                        }
                    },
                    toAddress: approvalData.token,
                    privateKey: privateKey
                )),
                try sign(coinType: input.coinType, input: buildBaseInputCustom(
                    input: input,
                    transaction: .with {
                        $0.contractGeneric = try EthereumTransaction.ContractGeneric.with {
                            $0.amount = swapData.asValue().magnitude.serialize()
                            $0.data = try Data.from(hex: swapData.data)
                        }
                    },
                    toAddress: swapData.to,
                    nonce: BigInt(try input.metadata.getSequence()) + 1,
                    gasLimit: swapData.gasLimitBigInt(),
                    privateKey: privateKey
                )),
            ]
        case .none:
            return [
                try sign(coinType: input.coinType, input: buildBaseInput(
                    input: input,
                    transaction: .with {
                        $0.contractGeneric = try EthereumTransaction.ContractGeneric.with {
                            $0.amount = swapData.asValue().magnitude.serialize()
                            $0.data = try Data.from(hex: swapData.data)
                        }
                    },
                    toAddress: swapData.to,
                    privateKey: privateKey
                ))
            ]
        }
    }
    
    public func signTokenApproval(input: SignerInput, privateKey: Data) throws -> String {
        guard case .tokenApprove(_, let approvalData) = input.type else {
            fatalError()
        }
        return try sign(coinType: input.coinType, input: buildBaseInput(
            input: input,
            transaction: .with {
                $0.erc20Approve = EthereumTransaction.ERC20Approve.with {
                    $0.spender = approvalData.spender
                    $0.amount = BigInt.MAX_256.magnitude.serialize()
                }
            },
            toAddress: approvalData.token,
            privateKey: privateKey
        ))
    }
    
    public func signStake(input: SignerInput, privateKey: Data) throws -> [String] {
        guard case .stake(_, let stakeType) = input.type else {
            fatalError("Invalid type for staking")
        }
        
        switch input.asset.chain {
        case .smartChain:
            guard
                case .evm(_, _, let stakeData) = input.metadata,
                let stakeData = stakeData,
                let data = stakeData.data,
                let to = stakeData.to else {
                throw AnyError("Invalid metadata for SmartChain staking")
            }
            
            let valueData: Data = switch stakeType {
            case .stake: input.value.magnitude.serialize()
            case .redelegate, .unstake, .rewards, .withdraw: Data()
            case .freeze: throw AnyError("Ethereum does not support freeze operations")
            }
            let callData = try Data.from(hex: data)
            
            let signedData = try sign(coinType: input.coinType, input: buildBaseInput(
                input: input,
                transaction: .with {
                    $0.contractGeneric = EthereumTransaction.ContractGeneric.with {
                        $0.amount = valueData
                        $0.data = callData
                    }
                },
                toAddress: to,
                privateKey: privateKey
            ))
            return [signedData]
        default:
            fatalError("\(input.asset.name) native staking not supported")
        }
    }
    
    public func signMessage(message: SignMessage, privateKey: Data) throws -> String {
        guard let privateKey = PrivateKey(data: privateKey) else {
            throw AnyError("Unable to get private key")
        }
        switch message {
        case .typed(let message):
            return EthereumMessageSigner.signTypedMessage(privateKey: privateKey, messageJson: message)
        }
    }
}
