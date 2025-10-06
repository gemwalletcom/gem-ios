// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import WalletCore

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
        
        if providers.contains(data.quote.providerData.provider) == false {
            throw AnyError("Invalid signing input type or not supported provider id")
        }

        if input.useMaxAmount && data.quote.providerData.provider == .chainflip {
            throw AnyError("Doesn't support swapping all amounts on Chainflip yet")
        }

        let opReturnIndex: UInt32? = switch data.quote.providerData.provider {
        case .thorchain: .none
        case .chainflip: 1
        default: .none
        }

        let opReturnData: Data = switch data.quote.providerData.provider {
        case .thorchain:
            try data.data.data.encodedData()
        case .chainflip: try {
            guard let data = Data(hexString: data.data.data) else {
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
        let utxos = try input.metadata.getUtxos().map {
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
        
        if coinType == .zcash {
            signingInput.plan = .with {
                $0.amount = input.value.asInt64
                $0.utxos = utxos
                $0.fee = 6000
                //$0.change = input.value.asInt64 - 6000
                $0.branchID = Data([0xbb, 0x09, 0xb8, 0x76])
            }
        }

//        if coinType == .zcash {
//            signingInput.byteFee = 0
//
//            let totalAvailable = utxos.reduce(into: Int64(0)) { result, utxo in
//                result += utxo.amount
//            }
//
//            guard totalAvailable >= ZcashSigner.staticFee else {
//                throw AnyError("Insufficient balance to cover Zcash fee")
//            }
//
//            let requestedAmount = signingInput.amount
//            let targetAmount = signingInput.useMaxAmount
//                ? max(totalAvailable - ZcashSigner.staticFee, 0)
//                : requestedAmount
//
//
//            let change = max(totalAvailable - targetAmount - ZcashSigner.staticFee, 0)
//
//            signingInput.amount = targetAmount
//            signingInput.zip0317 = true
//            signingInput.plan = BitcoinTransactionPlan.with {
//                $0.amount = targetAmount
//                $0.availableAmount = totalAvailable
//                $0.fee = input.fee.fee.asInt64
//                $0.change = change
//                $0.utxos = utxos
//                $0.branchID = ZcashSigner.branchId
//            }
//        }

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
