// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import Primitives
import BigInt

public struct NearSigner: Signable {
    public func signTransfer(input: SignerInput, privateKey: Data) throws -> String {
        let signingInput = try NEARSigningInput.with {
            $0.signerID = input.senderAddress
            $0.nonce = try input.metadata.getSequence()
            $0.receiverID = input.destinationAddress
            $0.actions = [
                NEARAction.with({
                    $0.transfer = NEARTransfer.with {
                        $0.deposit = input.value.littleEndianOrder(bytes: 16)
                    }
                }),
            ]
            $0.blockHash = try Base58.decodeNoCheck(string: input.metadata.getBlockHash())
            $0.privateKey = privateKey
        }
        let output: NEARSigningOutput = AnySigner.sign(input: signingInput, coin: input.asset.chain.coinType)
        
        if !output.errorMessage.isEmpty {
            throw AnyError(output.errorMessage)
        }
        
        return output.signedTransaction.base64EncodedString()
    }
}
    
