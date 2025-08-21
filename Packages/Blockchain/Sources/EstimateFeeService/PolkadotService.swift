// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient
import BigInt
import Gemstone
import GemstonePrimitives
import WalletCore

public final class PolkadotService: Sendable {
    
    public init() {
        
    }
    
    public func feePayload(input: TransactionInput) throws -> String {
        guard case .polkadot(
            let sequence,
            let genesisHash,
            let blockHash,
            let blockNumber,
            let specVersion,
            let transactionVersion,
            let period
        ) = input.metadata else {
            throw AnyError("")
        }
        
        let input = try PolkadotSigningInput.with {
            $0.genesisHash = try genesisHash.encodedData()
            $0.blockHash = try blockHash.encodedData()
            $0.nonce = UInt64(sequence)
            $0.specVersion = UInt32(specVersion)
            $0.network = CoinType.polkadot.ss58Prefix
            $0.transactionVersion = UInt32(transactionVersion)
            $0.privateKey = PrivateKey().data
            $0.era = PolkadotEra.with {
                $0.blockNumber = UInt64(blockNumber)
                $0.period = UInt64(period)
            }
            $0.balanceCall.transfer = PolkadotBalance.Transfer.with {
                $0.toAddress = input.destinationAddress
                $0.value = input.value.magnitude.serialize()
            }
        }
        let output: PolkadotSigningOutput = AnySigner.sign(input: input, coin: .polkadot)
        return output.encoded.hexString.append0x
    }
}

extension PolkadotService: GemGatewayEstimateFee {
    public func getFee(chain: Gemstone.Chain, input: Gemstone.GemTransactionLoadInput) async throws -> Gemstone.GemTransactionLoadFee? {
        return .none
    }
    
    public func getFeeData(chain: Gemstone.Chain, input: GemTransactionLoadInput) async throws -> String? {
        try feePayload(input: try input.map())
    }
}
