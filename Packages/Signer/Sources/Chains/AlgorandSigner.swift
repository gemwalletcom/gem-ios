// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import WalletCorePrimitives
import Blockchain
import Primitives

public struct AlgorandSigner: Signable {
    
    func sign(input: SignerInput, message: AlgorandSigningInput.OneOf_MessageOneof, privateKey: Data) throws -> String {
        let input = try AlgorandSigningInput.with {
            $0.genesisID = input.chainId
            $0.genesisHash = try input.block.hash.base64Encoded()
            if let memo = input.memo, !memo.isEmpty {
                $0.note = try memo.encodedData()
            }
            $0.firstRound = input.sequence.asUInt64
            $0.lastRound = input.sequence.asUInt64 + 1000
            $0.fee = input.fee.gasPrice.UInt
            $0.messageOneof = message
            $0.privateKey = privateKey
        }
        let output: AlgorandSigningOutput = AnySigner.sign(input: input, coin: .algorand)
        
        if !output.errorMessage.isEmpty {
            throw AnyError(output.errorMessage)
        }
        
        return output.encoded.hexString
    }
    
    public func signTransfer(input: SignerInput, privateKey: Data) throws -> String {
        let transfer = AlgorandTransfer.with {
            $0.toAddress = input.destinationAddress
            $0.amount = input.value.UInt
        }
        return try sign(
            input: input,
            message: .transfer(transfer),
            privateKey: privateKey
        )
    }
    
    public func signTokenTransfer(input: SignerInput, privateKey: Data) throws -> String {
        let tokenId = try input.asset.getTokenId()
        let transfer = AlgorandAssetTransfer.with {
            $0.toAddress = input.destinationAddress
            $0.amount = input.value.UInt
            $0.assetID = UInt64(tokenId)!
        }
        return try sign(
            input: input,
            message: .assetTransfer(transfer),
            privateKey: privateKey
        )
    }
    
    public func signData(input: Primitives.SignerInput, privateKey: Data) throws -> String {
        fatalError()
    }
    
    public func swap(input: SignerInput, privateKey: Data) throws -> String {
        fatalError()
    }
    
    public func signStake(input: SignerInput, privateKey: Data) throws -> [String] {
        fatalError()
    }
    
    public func signMessage(message: SignMessage, privateKey: Data) throws -> String {
        fatalError()
    }
}
    
