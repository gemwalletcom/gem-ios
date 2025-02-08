// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import WalletCorePrimitives
import Blockchain
import Primitives

public struct BitcoinSigner: Signable {
    public func signTransfer(input: SignerInput, privateKey: Data) throws -> String {
        return try sign(input: input, privateKey: privateKey, opreturn: .none)
    }
    
    public func signTokenTransfer(input: SignerInput, privateKey: Data) throws -> String {
        fatalError()
    }
    
    public func signData(input: Primitives.SignerInput, privateKey: Data) throws -> String {
        fatalError()
    }
    
    public func swap(input: SignerInput, privateKey: Data) throws -> [String] {
        guard case .swap(_, _, _, let data) = input.type else {
            throw AnyError("invalid type")
        }
        return [
            try sign(input: input, privateKey: privateKey, opreturn: data.data),
        ]
    }
    
    func sign(input: SignerInput, privateKey: Data, opreturn: String?) throws -> String {
        let coinType = input.coinType
        let utxos = input.utxos.map {
            $0.mapToUnspendTransaction(address: input.senderAddress, coinType: coinType)
        }
        let signingInput = try BitcoinSigningInput.with {
            $0.coinType = coinType.rawValue
            $0.hashType = BitcoinScript.hashTypeForCoin(coinType: coinType)
            $0.amount = input.value.asInt64
            $0.byteFee = input.fee.gasPrice.asInt64
            $0.toAddress = input.destinationAddress
            $0.changeAddress = input.senderAddress
            $0.utxo = utxos
            $0.privateKey = [privateKey]
            $0.scripts = utxos.mapToScripts(address: input.senderAddress, coinType: coinType)
            $0.useMaxAmount = input.useMaxAmount
            if let opreturn {
                $0.outputOpReturn = try opreturn.encodedData()
            }
        }
        let output: BitcoinSigningOutput = AnySigner.sign(input: signingInput, coin: coinType)
        
        if output.error != .ok {
            throw AnyError("\(output.error)")
        }
        
        if !output.errorMessage.isEmpty {
            throw AnyError(output.errorMessage)
        }
        
        return output.encoded.hexString
    }
}
