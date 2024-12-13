// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import WalletCorePrimitives
import Keystore
import Primitives

public struct AptosSigner: Signable {
    
    public func sign(payload: AptosSigningInput.OneOf_TransactionPayload, input: SignerInput , privateKey: Data) throws -> String {
        let signingInput = AptosSigningInput.with {
            $0.chainID = 1
            $0.transactionPayload = payload
            // TODO: - 3664390082 = 2086-22:08:02 +UTC, probably need to adjust
            $0.expirationTimestampSecs = 3664390082
            $0.gasUnitPrice = input.fee.gasPrice.UInt
            $0.maxGasAmount = input.fee.gasLimit.UInt
            $0.sequenceNumber = Int64(input.sequence)
            $0.sender = input.senderAddress
            $0.privateKey = privateKey
        }
        
        let output: AptosSigningOutput = AnySigner.sign(input: signingInput, coin: input.coinType)
        return output.json
    }
    
    public func signTransfer(input: SignerInput, privateKey: Data) throws -> String {
        return try sign(
            payload: .transfer(AptosTransferMessage.with {
                $0.to = input.destinationAddress
                $0.amount = input.value.UInt
            }),
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
            payload: .tokenTransferCoins(AptosTokenTransferCoinsMessage.with {
                $0.to = input.destinationAddress
                $0.amount = input.value.UInt
                $0.function = AptosStructTag.with {
                    $0.accountAddress = accountAddress
                    $0.module = module
                    $0.name = name
                }
            }),
            input: input,
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
