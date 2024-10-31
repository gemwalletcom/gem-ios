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
    
    internal func buildBaseInput(
        input: SignerInput,
        transaction: EthereumTransaction,
        toAddress: String,
        privateKey: Data
    ) -> EthereumSigningInput {
        return EthereumSigningInput.with {
            switch input.fee.gasPriceType {
            case .regular(let gasPrice):
                $0.txMode = .legacy
                $0.gasPrice = gasPrice.magnitude.serialize()
                fatalError("no longer supported")
            case .eip1559(let gasPrice, let minerFee):
                $0.txMode = .enveloped
                $0.maxFeePerGas = gasPrice.magnitude.serialize()
                $0.maxInclusionFeePerGas = minerFee.magnitude.serialize()
            }
            $0.gasLimit = input.fee.gasLimit.magnitude.serialize()
            $0.chainID = BigInt(stringLiteral: input.chainId).magnitude.serialize()
            $0.nonce = BigInt(input.sequence).magnitude.serialize()
            $0.transaction = transaction
            $0.toAddress = toAddress
            $0.privateKey = privateKey
        }
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
    
    public func swap(input: SignerInput, privateKey: Data) throws -> String {
        guard case .swap(_, _, let type) = input.type else {
            fatalError()
        }
        switch type {
        case .approval(let spender, let allowance):
            return try sign(coinType: input.coinType, input: buildBaseInput(
                input: input,
                transaction: .with {
                    $0.erc20Approve = EthereumTransaction.ERC20Approve.with {
                        $0.spender = spender
                        $0.amount = allowance.magnitude.serialize()
                    }
                },
                toAddress: input.asset.tokenId!,
                privateKey: privateKey
            ))
        case .swap(_, let swapData):
            let data = try Data.from(hex: swapData.data)
            return try sign(coinType: input.coinType, input: buildBaseInput(
                input: input,
                transaction: .with {
                    $0.contractGeneric = EthereumTransaction.ContractGeneric.with {
                        $0.amount = BigInt(stringLiteral: swapData.value).magnitude.serialize()
                        $0.data = data
                    }
                },
                toAddress: input.destinationAddress,
                privateKey: privateKey
            ))
        }
    }
    
    public func signStake(input: SignerInput, privateKey: Data) throws -> String {
        switch input.type.stakeChain {
        case .smartChain:
            return try SmartChainSigner().signStake(input: input, privateKey: privateKey)
        case .ethereum:
            return try LidoStakeSigner().signStake(input: input, privateKey: privateKey)
        default:
            fatalError()
        }
    }
}
