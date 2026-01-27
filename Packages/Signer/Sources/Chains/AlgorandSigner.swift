// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import Primitives

struct AlgorandSigner: Signable {
    
    func sign(input: SignerInput, message: AlgorandSigningInput.OneOf_MessageOneof, privateKey: Data) throws -> String {
        let input = try AlgorandSigningInput.with {
            $0.genesisID = try input.metadata.getChainId()
            $0.genesisHash = try input.metadata.getBlockHash().base64Encoded()
            if let memo = input.memo, !memo.isEmpty {
                $0.note = try memo.encodedData()
            }
            $0.firstRound = try input.metadata.getSequence()
            $0.lastRound = try input.metadata.getSequence() + 1000
            $0.fee = input.fee.gasPrice.asUInt
            $0.messageOneof = message
            $0.privateKey = privateKey
        }
        let output: AlgorandSigningOutput = AnySigner.sign(input: input, coin: .algorand)
        
        if !output.errorMessage.isEmpty {
            throw AnyError(output.errorMessage)
        }
        
        return output.encoded.hexString
    }
    
    func signTransfer(input: SignerInput, privateKey: Data) throws -> String {
        return try sign(
            input: input,
            message: .transfer(.with {
                $0.toAddress = input.destinationAddress
                $0.amount = input.value.asUInt
            }),
            privateKey: privateKey
        )
    }
    
    func signTokenTransfer(input: SignerInput, privateKey: Data) throws -> String {
        try sign(
            input: input,
            message: .assetTransfer(.with {
                $0.toAddress = input.destinationAddress
                $0.amount = input.value.asUInt
                $0.assetID = try input.asset.getTokenIdAsInt().asUInt64
            }),
            privateKey: privateKey
        )
    }
    
    func signAccountAction(input: SignerInput, privateKey: Data) throws -> String {
        try sign(
            input: input,
            message: .assetOptIn(.with {
                $0.assetID = try input.asset.getTokenIdAsInt().asUInt64
            }),
            privateKey: privateKey
        )
    }
}
    
