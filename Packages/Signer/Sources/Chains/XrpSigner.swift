// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import WalletCorePrimitives
import Blockchain
import Primitives

public struct XrpSigner: Signable {
    public func signTransfer(input: SignerInput, privateKey: Data) throws -> String {
        let signingInput = RippleSigningInput.with {
            $0.fee = input.fee.fee.int64
            $0.sequence = Int32(input.sequence)
            $0.account = input.senderAddress
            $0.privateKey = privateKey
            $0.operationOneof = .opPayment(
                RippleOperationPayment.with {
                    $0.destination = input.destinationAddress
                    $0.amount = input.value.int64
                    if let memo = input.memo, let destinationTag = Int64(memo) {
                        $0.destinationTag = destinationTag
                    }
                }
            )
        }
        
        let output: RippleSigningOutput = AnySigner.sign(input: signingInput, coin: input.coinType)
        return output.encoded.hexString
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
    
