// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import enum Gemstone.WalletConnectTransaction
import struct Gemstone.WcEthereumTransactionData
import struct Gemstone.WcSolanaTransactionData
import struct Gemstone.WcSuiTransactionData
import Primitives

extension WalletConnectTransaction {
    func map() -> WalletConnectorTransaction {
        switch self {
        case .ethereum(let data): .ethereum(data.map())
        case .solana(let data, let outputType): .solana(data.transaction, outputType.map())
        case .sui(let data, let outputType): .sui(data.transaction, outputType.map())
        case .ton(let messages, let outputType): .ton(messages, outputType.map())
        }
    }
}

extension WcEthereumTransactionData {
    func map() -> WCEthereumTransaction {
        WCEthereumTransaction(
            chainId: chainId,
            from: from,
            to: to,
            value: value,
            gas: gas,
            gasLimit: gasLimit,
            gasPrice: gasPrice,
            maxFeePerGas: maxFeePerGas,
            maxPriorityFeePerGas: maxPriorityFeePerGas,
            nonce: nonce,
            data: data
        )
    }
}
