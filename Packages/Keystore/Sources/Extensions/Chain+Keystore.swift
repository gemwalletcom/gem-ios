import Foundation
import Primitives
import WalletCore
import WalletCorePrimitives

public extension Chain {

    var defaultKeyEncodingType: EncodingType {
        keyEncodingTypes.first!
    }

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
            .near,
            .bitcoin:
            [.hex]
        }
    }

    func isValidAddress(_ address: String) -> Bool {
        return AnyAddress.isValid(string: address, coin: coinType)
    }
}
