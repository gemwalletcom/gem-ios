// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Foundation
import Gemstone
import Primitives
import SwiftHTTPClient
import WalletCore

internal import GemstonePrimitives

final class CardanoService: Sendable {

    init() {

    }

    private func calculateFee(input: TransactionInput) async throws -> Gemstone.GemTransactionLoadFee? {
        let utxos = try input.metadata.getUtxos()
        let signingInput = try CardanoSigningInput.with {
            $0.utxos = try utxos.map { utxo in
                try CardanoTxInput.with {
                    $0.outPoint.txHash = try Data.from(hex: utxo.transaction_id)
                    $0.outPoint.outputIndex = UInt64(utxo.vout)
                    $0.address = utxo.address
                    $0.amount = try UInt64(string: utxo.value)
                }
            }
            $0.transferMessage.toAddress = input.destinationAddress
            $0.transferMessage.changeAddress = input.senderAddress
            $0.transferMessage.amount = input.value.asUInt
            $0.transferMessage.useMaxAmount = input.feeInput.isMaxAmount
            $0.ttl = 190000000
        }
        let plan: CardanoTransactionPlan = AnySigner.plan(input: signingInput, coin: .cardano)

        return Fee(
            fee: BigInt(plan.fee),
            gasPriceType: .regular(gasPrice: 1),
            gasLimit: 1
        ).map()
    }
}

extension CardanoService: GemGatewayEstimateFee {
    public func getFee(chain: Gemstone.Chain, input: Gemstone.GemTransactionLoadInput) async throws -> Gemstone.GemTransactionLoadFee? {
        return try await calculateFee(input: try input.map())
    }

    public func getFeeData(chain: Gemstone.Chain, input: GemTransactionLoadInput) async throws -> String? {
        .none
    }
}
