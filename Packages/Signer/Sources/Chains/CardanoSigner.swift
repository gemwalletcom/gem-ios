// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import WalletCorePrimitives
import Blockchain
import Primitives

public struct CardanoSigner: Signable {
    
    public func signTransfer(input: SignerInput, privateKey: Data) throws -> String {
        var signingInput = CardanoSigningInput.with {
            $0.transferMessage.toAddress = input.destinationAddress
            $0.transferMessage.changeAddress = input.senderAddress
            $0.transferMessage.amount = input.value.asUInt
            $0.transferMessage.useMaxAmount = input.useMaxAmount
            $0.ttl = 190000000
        }
        signingInput.privateKey.append(privateKey)
        signingInput.utxos = try input.utxos.map { utxo in
            try CardanoTxInput.with {
                $0.outPoint.txHash = try Data.from(hex: utxo.transaction_id)
                $0.outPoint.outputIndex = UInt64(utxo.vout)
                $0.address = try utxo.address.unwrapOrThrow()
                $0.amount = try UInt64(string: utxo.value)
            }
        }
        
        let output: CardanoSigningOutput = AnySigner.sign(input: signingInput, coin: .cardano)

        if !output.errorMessage.isEmpty {
            throw AnyError(output.errorMessage)
        }

        return output.encoded.hexString
    }
}
    
