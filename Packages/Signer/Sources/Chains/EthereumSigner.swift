// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import WalletCorePrimitives
import BigInt
import Keystore
import Primitives
import Blockchain

public class EthereumSigner: Signable {

    public func signTransfer(input: SignerInput, privateKey: Data) throws -> String {
        let base = buildBaseInput(
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
        let base = buildBaseInput(
            input: input,
            transaction: .with {
                $0.erc20Transfer = EthereumTransaction.ERC20Transfer.with {
                    $0.to = input.destinationAddress
                    $0.amount = input.value.magnitude.serialize()
                }
            },
            toAddress: input.asset.tokenId!,
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
        
        let base = buildBaseInput(
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
    ) -> EthereumSigningInput {
        return EthereumSigningInput.with {
            switch input.fee.gasPriceType {
            case .regular(let gasPrice):
                $0.txMode = .legacy
                $0.gasPrice = gasPrice.magnitude.serialize()
                fatalError("no longer supported")
            case .eip1559(let gasPrice, let priorityFee):
                $0.txMode = .enveloped
                $0.maxFeePerGas = gasPrice.magnitude.serialize()
                $0.maxInclusionFeePerGas = priorityFee.magnitude.serialize()
            }
            $0.gasLimit = gasLimit.magnitude.serialize()
            $0.chainID = BigInt(stringLiteral: input.chainId).magnitude.serialize()
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
    ) -> EthereumSigningInput {
        buildBaseInputCustom(
            input: input,
            transaction: transaction,
            toAddress: toAddress,
            nonce: BigInt(input.sequence),
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
        let base = buildBaseInput(
            input: input,
            transaction: .with {
                $0.contractGeneric = EthereumTransaction.ContractGeneric.with {
                    $0.amount = input.value.magnitude.serialize()
                    if let data = input.type.data {
                        $0.data = data
                    }
                }
            },
            toAddress: input.destinationAddress,
            privateKey: privateKey
        )
        return try sign(coinType: input.coinType, input: base)
    }
    
    public func swap(input: SignerInput, privateKey: Data) throws -> [String] {
        guard case .swap(_, _, _, let swapData) = input.type else {
            fatalError()
        }
        var transactions: [String] = []
        
        if let approvalData = swapData.approval {
            let approvalTransaction = try sign(coinType: input.coinType, input: buildBaseInputCustom(
                input: input,
                transaction: .with {
                    $0.erc20Approve = EthereumTransaction.ERC20Approve.with {
                        $0.spender = approvalData.spender
                        $0.amount = BigInt.MAX_256.magnitude.serialize()
                    }
                },
                toAddress: try input.asset.getTokenId(),
                nonce: input.sequence.asBigInt,
                gasLimit: input.fee.gasLimit,
                privateKey: privateKey
            ))
            transactions.append(approvalTransaction)
        }
        
        let swapTransaction = try sign(coinType: input.coinType, input: buildBaseInputCustom(
            input: input,
            transaction: .with {
                $0.contractGeneric = try EthereumTransaction.ContractGeneric.with {
                    $0.amount = BigInt(stringLiteral: swapData.value.remove0x).magnitude.serialize()
                    $0.data = try Data.from(hex: swapData.data)
                }
            },
            toAddress: input.destinationAddress,
            nonce: input.sequence.asBigInt + 1,
            gasLimit: input.fee.gasLimit,
            privateKey: privateKey
        ))
        transactions.append(swapTransaction)
        
        return transactions
    }
    
    public func signStake(input: SignerInput, privateKey: Data) throws -> [String] {
        switch input.type.stakeChain {
        case .smartChain:
            return try SmartChainSigner().signStake(input: input, privateKey: privateKey)
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
