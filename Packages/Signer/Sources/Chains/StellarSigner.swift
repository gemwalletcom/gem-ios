// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import Primitives

struct StellarSigner: Signable {
    
    func sign(input: SignerInput, operation: StellarSigningInput.OneOf_OperationOneof,  privateKey: Data) throws -> String {
        let input = try StellarSigningInput.with {
            $0.passphrase = StellarPassphrase.stellar.description
            $0.fee = Int32(input.fee.totalFee)
            $0.sequence = Int64(try input.metadata.getSequence())
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
    
    func signTransfer(input: SignerInput, privateKey: Data) throws -> String {
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
    
    func signTokenTransfer(input: SignerInput, privateKey: Data) throws -> String {
        let (issuer, symbol) = try input.asset.id.twoSubTokenIds()
        return try sign(
            input: input,
            operation: .opPayment(.with {
                $0.asset = .with {
                    $0.alphanum4 = symbol
                    $0.issuer = issuer
                }
                $0.destination = input.destinationAddress
                $0.amount = input.value.asInt64
            }),
            privateKey: privateKey
        )
    }
    
    func signAccountAction(input: SignerInput, privateKey: Data) throws -> String {
        let (issuer, symbol) = try input.asset.id.twoSubTokenIds()
        return try sign(
            input: input,
            operation: .opChangeTrust(.with {
                $0.asset = .with {
                    $0.issuer = issuer
                    $0.alphanum4 = symbol
                }
            }),
            privateKey: privateKey
        )
    }
}
    
