// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import WalletCorePrimitives
import Blockchain
import Primitives
import BigInt

public struct NearSigner: Signable {
    public func signTransfer(input: SignerInput, privateKey: Data) throws -> String {
        let signingInput = NEARSigningInput.with {
            $0.signerID = input.senderAddress
            $0.nonce = input.sequence.asUInt64
            $0.receiverID = input.destinationAddress
            $0.actions = [
                NEARAction.with({
                    $0.transfer = NEARTransfer.with {
                        $0.deposit = input.value.littleEndianOrder(bytes: 16)
                    }
                }),
            ]
            $0.blockHash = Base58.decodeNoCheck(string: input.block.hash)!
            $0.privateKey = privateKey
        }
        let output: NEARSigningOutput = AnySigner.sign(input: signingInput, coin: input.asset.chain.coinType)
        
        if !output.errorMessage.isEmpty {
            throw AnyError(output.errorMessage)
        }
        
        return output.signedTransaction.base64EncodedString()
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
    
