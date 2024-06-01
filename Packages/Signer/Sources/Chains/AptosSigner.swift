// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import WalletCorePrimitives
import Keystore
import Primitives

public struct AptosSigner: Signable {
    
    public func signTransfer(input: SignerInput, privateKey: Data) throws -> String {
        let signingInput = AptosSigningInput.with {
            $0.chainID = 1
            $0.transactionPayload = .transfer(AptosTransferMessage.with {
                $0.to = input.destinationAddress
                $0.amount = input.value.UInt
            })
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
    
    public func signTokenTransfer(input: SignerInput, privateKey: Data) throws -> String {
       fatalError()
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
}
