// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import Keystore
import Primitives

enum AptosPayload {
    case payload(AptosSigningInput.OneOf_TransactionPayload)
    case anyData(String)
}

public struct AptosSigner: Signable {
    
    func sign(payload: AptosPayload, input: SignerInput , privateKey: Data) throws -> String {
        let signingInput = try AptosSigningInput.with {
            $0.chainID = 1
            switch payload {
            case .payload(let payload):
                $0.transactionPayload = payload
            case .anyData(let string):
                $0.anyEncoded = string
            }
            $0.expirationTimestampSecs = UInt64(Date.now.timeIntervalSince1970) + 3_600
            $0.gasUnitPrice = input.fee.gasPrice.asUInt
            $0.maxGasAmount = input.fee.gasLimit.asUInt
            $0.sequenceNumber = Int64(try input.metadata.getSequence())
            $0.sender = input.senderAddress
            $0.privateKey = privateKey
        }
        let output: AptosSigningOutput = AnySigner.sign(input: signingInput, coin: input.coinType)
        
        if !output.errorMessage.isEmpty {
            throw AnyError(output.errorMessage)
        }
        
        return output.json
    }
    
    public func signTransfer(input: SignerInput, privateKey: Data) throws -> String {
        return try sign(
            payload: .payload(.transfer(AptosTransferMessage.with {
                $0.to = input.destinationAddress
                $0.amount = input.value.asUInt
            })),
            input: input,
            privateKey: privateKey
        )
    }
    
    public func signTokenTransfer(input: SignerInput, privateKey: Data) throws -> String {
        let parts: [String] = try input.asset.getTokenId().split(separator: "::").map { String($0) }
        let accountAddress = try parts.getElement(safe: 0)
        let module = try parts.getElement(safe: 1)
        let name = try parts.getElement(safe: 2)
        
        return try sign(
            payload: .payload(.tokenTransferCoins(AptosTokenTransferCoinsMessage.with {
                $0.to = input.destinationAddress
                $0.amount = input.value.asUInt
                $0.function = AptosStructTag.with {
                    $0.accountAddress = accountAddress
                    $0.module = module
                    $0.name = name
                }
            })),
            input: input,
            privateKey: privateKey
        )
    }
    
    public func signData(input: Primitives.SignerInput, privateKey: Data) throws -> String {
        fatalError()
    }
    
    public func signSwap(input: SignerInput, privateKey: Data) throws -> [String] {
        let data = try input.type.swap().data
        return [
            try sign(payload: .anyData(data.data.data), input: input, privateKey: privateKey)
        ]
    }

    public func signStake(input: SignerInput, privateKey: Data) throws -> [String] {
        guard case .aptos(_, let data) = input.metadata, let stakeData = data else {
            throw AnyError("Invalid metadata for Aptos staking")
        }
        return [
            try sign(payload: .anyData(try input.metadata.getData()), input: input, privateKey: privateKey)
        ]
    }
}
