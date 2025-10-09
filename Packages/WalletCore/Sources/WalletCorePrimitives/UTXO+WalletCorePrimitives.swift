// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import Primitives

public extension UTXO {
    func mapToUnspendTransaction(address: String, coinType: CoinType) -> BitcoinUnspentTransaction {
        BitcoinUnspentTransaction.with {
            $0.outPoint.hash = Data.reverse(hexString: transaction_id)
            $0.outPoint.index = UInt32(vout)
            $0.amount = Int64(value)!
            $0.script = BitcoinScript.lockScriptForAddress(address: address, coin: coinType).data
        }
    }
}

public extension Array where Element == BitcoinUnspentTransaction {
    func mapToScripts(address: String, coinType: CoinType) -> [String : Data] {
        return reduce(into: [String: Data]()) { map, data in
            let script = BitcoinScript.lockScriptForAddress(address: address, coin: coinType)
            
            guard coinType != .bitcoin, !script.data.isEmpty else {
                return
            }
            if let scriptHash = script.matchPayToScriptHash() {
                map[scriptHash.hexString] = script.matchPayToWitnessPublicKeyHash()
            } else if let scriptHash = script.matchPayToWitnessPublicKeyHash() {
                map[scriptHash.hexString] = script.matchPayToPubkeyHash()
            }
       }
    }
}
