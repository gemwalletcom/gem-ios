// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import WalletCorePrimitives
import Blockchain
import Primitives

public struct PolkadotSigner: Signable {
    
    func sign(input: SignerInput, message: PolkadotSigningInput.OneOf_MessageOneof, privateKey: Data) throws -> String {
        guard case let .polkadot(data) = input.data else {
            throw SignerError.incompleteData
        }
        let input = PolkadotSigningInput.with {
            $0.genesisHash = data.genesisHash
            $0.blockHash = data.blockHash
            $0.nonce = input.sequence.asUInt64
            $0.specVersion = data.specVersion
            $0.network = CoinType.polkadot.ss58Prefix
            $0.transactionVersion = data.transactionVersion
            $0.privateKey = privateKey
            $0.era = PolkadotEra.with {
                $0.blockNumber = data.blockNumber
                $0.period = data.period
            }
            $0.messageOneof = message
        }
        let output: PolkadotSigningOutput = AnySigner.sign(input: input, coin: .polkadot)
        
        if !output.errorMessage.isEmpty {
            throw AnyError(output.errorMessage)
        }
        
        return output.encoded.hexString.append0x
    }
    
    public func signTransfer(input: SignerInput, privateKey: Data) throws -> String {
        return try sign(
            input: input,
            message: .balanceCall(.with {
                $0.transfer = PolkadotBalance.Transfer.with {
                    $0.toAddress = input.destinationAddress
                    $0.value = input.value.magnitude.serialize()
                }
            }),
            privateKey: privateKey
        )
    }
}
    
