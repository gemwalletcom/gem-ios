// Copyright (c). Gem Wallet. All rights reserved.

import Blockchain
import Foundation
import Primitives
import WalletCore
import WalletCorePrimitives

public struct BitcoinSigner: Signable {
    public func signTransfer(input: SignerInput, privateKey: Data) throws -> String {
        return try sign(input: input, privateKey: privateKey)
    }

    public func signTokenTransfer(input: SignerInput, privateKey: Data) throws -> String {
        fatalError()
    }

    public func signData(input: Primitives.SignerInput, privateKey: Data) throws -> String {
        fatalError()
    }

    public func signSwap(input: SignerInput, privateKey: Data) throws -> [String] {
        let (_, _, data) = try input.type.swap()
        let providers = Set([SwapProvider.thorchain, .chainflip])
        
        if providers.contains(data.quote.provider) == false {
            throw AnyError("Invalid signing input type or not supported provider id")
        }

        if input.useMaxAmount && data.quote.provider == .chainflip {
            throw AnyError("Doesn't support swapping all amounts on Chainflip yet")
        }

        let opReturnIndex: UInt32? = switch data.quote.provider {
        case .thorchain: .none
        case .chainflip: 1
        default: .none
        }

        let opReturnData: Data = switch data.quote.provider {
        case .thorchain:
            try data.data.encodedData()
        case .chainflip: try {
                guard let data = Data(hexString: data.data) else {
                    throw AnyError("Invalid Chainflip swap data")
                }
                return data
            }()
        default: fatalError()
        }

        return try [
            sign(input: input, privateKey: privateKey) { signingInput in
                if let opReturnIndex = opReturnIndex {
                    signingInput.outputOpReturnIndex.index = opReturnIndex
                }
                signingInput.outputOpReturn = opReturnData
            }
        ]
    }

    func sign(input: SignerInput, privateKey: Data, signingOverride: ((inout BitcoinSigningInput) -> Void)? = nil) throws -> String {
        let coinType = input.coinType
        let utxos = input.utxos.map {
            $0.mapToUnspendTransaction(address: input.senderAddress, coinType: coinType)
        }

        var signingInput = BitcoinSigningInput.with {
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
        }
        signingOverride?(&signingInput)
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
