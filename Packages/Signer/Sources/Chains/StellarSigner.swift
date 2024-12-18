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
            let operation = StellarOperationCreateAccount.with {
                $0.destination = input.destinationAddress
                $0.amount = input.value.int64
            }
            return try sign(
                input: input,
                operation: .opCreateAccount(operation),
                privateKey: privateKey
            )
        } else {
            let operation = StellarOperationPayment.with {
                $0.destination = input.destinationAddress
                $0.amount = input.value.int64
            }
            return try sign(
                input: input,
                operation: .opPayment(operation),
                privateKey: privateKey
            )
        }
    }
    
    public func signTokenTransfer(input: SignerInput, privateKey: Data) throws -> String {
        fatalError()
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
    
