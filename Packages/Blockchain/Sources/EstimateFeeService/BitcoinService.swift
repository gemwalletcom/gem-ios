// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient
import BigInt
import WalletCore
import Gemstone

public final class BitcoinService: Sendable {
    
    let chain: BitcoinChain
    
    public init(
        chain: BitcoinChain
    ) {
        self.chain = chain
    }
    
    private func calculateFee(input: TransactionInput) async throws -> Gemstone.GemTransactionLoadFee? {
        let utxos = try input.metadata.getUtxos()
        
        guard input.value <= BigInt(Int64.max) else {
            throw ChainCoreError.incorrectAmount
        }
        
        let primitiveChain = input.asset.chain
        let coinType = primitiveChain.coinType
        let senderAddress = input.senderAddress
        let destinationAddress = input.destinationAddress
        let gasPrice = input.gasPrice.gasPrice
        
        let utxo = utxos.map { $0.mapToUnspendTransaction(address: senderAddress, coinType: coinType) }
        let scripts = utxo.mapToScripts(address: senderAddress, coinType: coinType)
        let hashType = BitcoinScript.hashTypeForCoin(coinType: coinType)

        let signingInput = BitcoinSigningInput.with {
            $0.coinType = coinType.rawValue
            $0.hashType = hashType
            $0.amount = input.value.asInt64
            $0.byteFee = gasPrice.asInt64
            $0.toAddress = destinationAddress
            $0.changeAddress = senderAddress
            $0.utxo = utxo
            $0.scripts = scripts
            $0.useMaxAmount = input.feeInput.isMaxAmount
        }
        let plan: BitcoinTransactionPlan = AnySigner.plan(input: signingInput, coin: coinType)

        try ChainCoreError.fromWalletCore(for: primitiveChain, plan.error)
        
        return Fee(
            fee: BigInt(plan.fee),
            gasPriceType: .regular(gasPrice: gasPrice),
            gasLimit: 1
        ).map()
    }
}

extension BitcoinService: GemGatewayEstimateFee {
    public func getFee(chain: Gemstone.Chain, input: Gemstone.GemTransactionLoadInput) async throws -> Gemstone.GemTransactionLoadFee? {
        return try await calculateFee(input: try input.map())
    }
    
    public func getFeeData(chain: Gemstone.Chain, input: GemTransactionLoadInput) async throws -> String? {
        .none
    }
}
