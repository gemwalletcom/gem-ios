// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension TransactionLoadInput {
    public func map() -> GemTransactionLoadInput {
        GemTransactionLoadInput(
            inputType: inputType.map(),
            senderAddress: senderAddress,
            destinationAddress: destinationAddress,
            value: value,
            gasPrice: GemGasPrice(gasPrice: gasPrice.gasPrice.description),
            sequence: sequence,
            blockHash: blockHash,
            blockNumber: blockNumber,
            chainId: chainId,
            utxos: utxos.map { $0.map() }
        )
    }
}

extension TransactionInputType {
    public func map() -> GemTransactionInputType {
        switch self {
        case .transfer(let asset):
            return .transfer(asset: asset.map())
        }
    }
}

extension Asset {
    public func map() -> GemAsset {
        GemAsset(
            id: id.identifier,
            name: name,
            symbol: symbol,
            decimals: decimals,
            assetType: type.rawValue
        )
    }
}

extension UTXO {
    public func map() -> GemUtxo {
        GemUtxo(
            transactionId: transaction_id,
            vout: UInt32(vout),
            value: value,
            address: address
        )
    }
}
