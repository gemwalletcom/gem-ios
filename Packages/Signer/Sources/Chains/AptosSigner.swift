// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import WalletCorePrimitives
import Keystore
import Primitives

enum AptosPayload {
    case payload(AptosSigningInput.OneOf_TransactionPayload)
    case anyData(String)
}

public struct AptosSigner: Signable {
    
    func sign(payload: AptosPayload, input: SignerInput , privateKey: Data) throws -> String {
        let signingInput = AptosSigningInput.with {
            $0.chainID = 1
            switch payload {
            case .payload(let payload):
                $0.transactionPayload = payload
            case .anyData(let string):
                $0.anyEncoded = string
            }
            // TODO: - 3664390082 = 2086-22:08:02 +UTC, probably need to adjust
            $0.expirationTimestampSecs = 3664390082
            $0.gasUnitPrice = input.fee.gasPrice.asUInt
            $0.maxGasAmount = input.fee.gasLimit.asUInt
            $0.sequenceNumber = Int64(input.sequence)
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
    
    public func swap(input: SignerInput, privateKey: Data) throws -> String {
        guard case .swap(_, _, let action) = input.type else {
            throw AnyError("invalid type")
        }
        switch action {
        case .swap(_, let data):
            return try sign(payload: .anyData(data.data), input: input, privateKey: privateKey)
        case .approval:
            fatalError()
        }
    }
}
