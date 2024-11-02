// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import WalletCorePrimitives
import Blockchain
import Primitives

public struct TronSigner: Signable {
    public func signTransfer(input: SignerInput, privateKey: Data) throws -> String {
        let contract = TronTransferContract.with {
            $0.ownerAddress = input.senderAddress
            $0.toAddress = input.destinationAddress
            $0.amount = input.value.int64
        }
        let signingInput = try prepareSigningInput(block: input.block, contract: .transfer(contract), feeLimit: .none, privateKey: privateKey)
        let output: TronSigningOutput = AnySigner.sign(input: signingInput, coin: input.coinType)
        return output.json
    }
    
    public func signTokenTransfer(input: SignerInput, privateKey: Data) throws -> String {
        let contract = TronTransferTRC20Contract.with {
            $0.contractAddress = input.asset.tokenId!
            $0.ownerAddress = input.senderAddress
            $0.toAddress = input.destinationAddress
            $0.amount = input.value.magnitude.serialize()
        }
        let signingInput = try prepareSigningInput(block: input.block, contract: .transferTrc20Contract(contract), feeLimit: input.fee.gasPrice.int, privateKey: privateKey)
        let output: TronSigningOutput = AnySigner.sign(input: signingInput, coin: input.coinType)
        return output.json
    }
    
    func prepareSigningInput(
        block: SignerInputBlock,
        contract: WalletCore.TronTransaction.OneOf_ContractOneof,
        feeLimit: Int?,
        privateKey: Data
    ) throws -> TronSigningInput {
        let transactionTreeRoot = try Data.from(hex: block.transactionTreeRoot)
        let parentHash = try Data.from(hex: block.parentHash)
        let witnessAddress = try Data.from(hex: block.widnessAddress)
        
        return TronSigningInput.with {
            $0.transaction = TronTransaction.with {
                $0.contractOneof = contract
                $0.timestamp = Int64(block.timestamp)
                $0.blockHeader = TronBlockHeader.with {
                    $0.timestamp = Int64(block.timestamp)
                    $0.number = Int64(block.number)
                    $0.version = Int32(block.version)
                    $0.txTrieRoot = transactionTreeRoot
                    $0.parentHash = parentHash
                    $0.witnessAddress = witnessAddress
                }
                if let feeLimit = feeLimit {
                    $0.feeLimit = Int64(feeLimit)
                }
                $0.expiration = Int64(block.timestamp) + 10 * 60 * 60 * 1000
            }
            $0.privateKey = privateKey
        }
    }
    
    public func signData(input: Primitives.SignerInput, privateKey: Data) throws -> String {
        fatalError()
    }
    
    public func swap(input: SignerInput, privateKey: Data) throws -> String {
        fatalError()
    }
    
    public func signStake(input: SignerInput, privateKey: Data) throws -> String {
        fatalError()
    }
    
    public func signMessage(message: SignMessage, privateKey: Data) throws -> String {
        fatalError()
    }
}
