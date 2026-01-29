// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import WalletCore

struct BitcoinSigner: Signable {
    func signTransfer(input: SignerInput, privateKey: Data) throws -> String {
        return try sign(input: input, privateKey: privateKey)
    }

    func signTokenTransfer(input: SignerInput, privateKey: Data) throws -> String {
        fatalError()
    }

    func signData(input: Primitives.SignerInput, privateKey: Data) throws -> String {
        fatalError()
    }

    func sign(input: SignerInput, privateKey: Data) throws -> String {
        let coinType = input.coinType
        let utxos = try input.metadata.getUtxos().map {
            $0.mapToUnspendTransaction(address: input.senderAddress, coinType: coinType)
        }

        if coinType == .zcash {
            return try signZcash(
                input: input,
                coinType: coinType,
                privateKey: privateKey,
                utxos: utxos
            )
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
            if let memo = input.memo {
                $0.outputOpReturn = try memo.encodedData()
            }
            $0.scripts = utxos.mapToScripts(address: input.senderAddress, coinType: coinType)
            $0.useMaxAmount = input.useMaxAmount
        }

        return try performSigning(signingInput: signingInput, coinType: coinType)
    }

    private func signZcash(
        input: SignerInput,
        coinType: CoinType,
        privateKey: Data,
        utxos: [BitcoinUnspentTransaction]
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
