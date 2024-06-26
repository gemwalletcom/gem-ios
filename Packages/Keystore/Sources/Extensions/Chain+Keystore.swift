import Foundation
import Primitives
import WalletCore
import WalletCorePrimitives

public extension Chain {

    var keyEncodingTypes: [EncodingType] {
        switch self.type {
        case .solana:
            [.base58, .hex]
        case .ethereum,
            .cosmos,
            .ton,
            .tron,
            .aptos,
            .sui,
            .xrp,
            .near:
            [.hex]
        case .bitcoin:
            []
        }
    }

    func isValidAddress(_ address: String) -> Bool {
        return AnyAddress.isValid(string: address, coin: coinType)
    }
}
