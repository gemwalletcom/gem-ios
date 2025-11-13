// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import Primitives

public struct PolkadotSigner: Signable {
    
    func sign(input: SignerInput, message: PolkadotSigningInput.OneOf_MessageOneof, privateKey: Data) throws -> String {
        guard case let .polkadot(sequence, genesisHash, blockHash, blockNumber, specVersion, transactionVersion, period) = input.metadata else {
            throw SignerError.incompleteData
        }
        let input = try PolkadotSigningInput.with {
            $0.genesisHash = try Data.from(hex: genesisHash)
            $0.blockHash = try Data.from(hex: blockHash)
            $0.nonce = sequence
            $0.specVersion = UInt32(specVersion)
            $0.network = CoinType.polkadot.ss58Prefix
            $0.transactionVersion = UInt32(transactionVersion)
            $0.privateKey = privateKey
            $0.chargeNativeAsAssetTxPayment = true
            $0.era = PolkadotEra.with {
                $0.blockNumber = UInt64(blockNumber)
                $0.period = UInt64(period)
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
                $0.transfer = .with {
                    $0.toAddress = input.destinationAddress
                    $0.value = input.value.magnitude.serialize()
                    $0.callIndices = .with {
                        $0.variant = .custom(.with {
                            $0.moduleIndex = 0x0A
                            $0.methodIndex = 0x00
                        })
                    }
                }
            }),
            privateKey: privateKey
        )
    }
}
    
