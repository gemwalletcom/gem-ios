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

        if input.useMaxAmount, data.quote.providerData.provider == .chainflip {
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
        case .chainflip:
            try Data.from(hex: data.data.data)
        default: fatalError()
        }

        return try [
            sign(input: input, privateKey: privateKey) { signingInput in
                if let opReturnIndex = opReturnIndex {
                    signingInput.outputOpReturnIndex.index = opReturnIndex
                }
                signingInput.toAddress = data.data.to
                signingInput.outputOpReturn = opReturnData
            }
        ]
    }

    func sign(input: SignerInput, privateKey: Data, signingOverride: ((inout BitcoinSigningInput) -> Void)? = nil) throws -> String {
        let coinType = input.coinType
        let utxos = try input.metadata.getUtxos().map {
            $0.mapToUnspendTransaction(address: input.senderAddress, coinType: coinType)
        }

        if coinType == .zcash {
            return try signZcash(
                input: input,
                coinType: coinType,
                privateKey: privateKey,
                utxos: utxos,
                signingOverride: signingOverride
            )
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

        return try performSigning(signingInput: signingInput, coinType: coinType)
    }

    private func signZcash(
        input: SignerInput,
        coinType: CoinType,
        privateKey: Data,
        utxos: [BitcoinUnspentTransaction],
        signingOverride: ((inout BitcoinSigningInput) -> Void)?
    ) throws -> String {
        guard case .zcash(_, let branchId) = input.metadata else {
            throw AnyError("invalid zcash metadata")
        }
        var signingInput = BitcoinSigningInput.with {
            $0.coinType = coinType.rawValue
            $0.hashType = BitcoinScript.hashTypeForCoin(coinType: coinType)
            $0.amount = input.value.asInt64
            $0.byteFee = 0
            $0.toAddress = input.destinationAddress
            $0.changeAddress = input.senderAddress
            $0.utxo = utxos
            $0.privateKey = [privateKey]
            $0.scripts = utxos.mapToScripts(address: input.senderAddress, coinType: coinType)
            $0.useMaxAmount = input.useMaxAmount
        }

        signingOverride?(&signingInput)

        let totalAvailable = utxos.reduce(into: Int64(0)) { result, utxo in
            result += utxo.amount
        }

        let fee = input.fee.fee.asInt64

        guard totalAvailable >= fee else {
            throw AnyError("Insufficient balance to cover Zcash fee")
        }

        let requestedAmount = signingInput.amount
        let targetAmount = signingInput.useMaxAmount ? max(totalAvailable - fee, 0) : requestedAmount

        guard totalAvailable - fee >= targetAmount else {
            throw AnyError("Insufficient balance to cover Zcash amount and fee")
        }

        let change = max(totalAvailable - targetAmount - fee, 0)
        
        signingInput.amount = targetAmount
        signingInput.zip0317 = false
        signingInput.plan = try BitcoinTransactionPlan.with {
            $0.amount = targetAmount
            $0.availableAmount = totalAvailable
            $0.fee = fee
            $0.change = change
            $0.utxos = utxos
            $0.branchID = Data(try Data.from(hex: branchId).reversed())
        }

        return try performSigning(signingInput: signingInput, coinType: coinType)
    }

    private func performSigning(signingInput: BitcoinSigningInput, coinType: CoinType) throws -> String {
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
