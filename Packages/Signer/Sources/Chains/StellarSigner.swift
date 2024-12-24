// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import WalletCorePrimitives
import Blockchain
import Primitives

public struct StellarSigner: Signable {
    
    func sign(input: SignerInput, operation: StellarSigningInput.OneOf_OperationOneof,  privateKey: Data) throws -> String {
        let input = StellarSigningInput.with {
            $0.passphrase = StellarPassphrase.stellar.description
            $0.fee = Int32(input.fee.totalFee)
            $0.sequence = Int64(input.sequence)
            $0.account = input.senderAddress
            if let memo = input.memo {
                $0.memoText = .with {
                    $0.text = memo
                }
            }
            $0.operationOneof = operation
            $0.privateKey = privateKey
        }
        let output: StellarSigningOutput = AnySigner.sign(input: input, coin: .stellar)
        
        if !output.errorMessage.isEmpty {
            throw AnyError(output.errorMessage)
        }
        
        return output.signature
    }
    
    public func signTransfer(input: SignerInput, privateKey: Data) throws -> String {
        if input.fee.options.contains(where:  { $0.key == .tokenAccountCreation }) {
            try sign(
                input: input,
                operation: .opCreateAccount(.with {
                    $0.destination = input.destinationAddress
                    $0.amount = input.value.asInt64
                }),
                privateKey: privateKey
            )
        } else {
            try sign(
                input: input,
                operation: .opPayment(.with {
                    $0.destination = input.destinationAddress
                    $0.amount = input.value.asInt64
                }),
                privateKey: privateKey
            )
        }
    }
    
    public func signAccountAction(input: SignerInput, privateKey: Data) throws -> String {
        try sign(
            input: input,
            operation: .opChangeTrust(.with {
                $0.asset = try .with {
                    $0.issuer = try input.asset.getTokenId()
                    $0.alphanum4 = input.asset.symbol
                }
            }),
            privateKey: privateKey
        )
    }
}
    
