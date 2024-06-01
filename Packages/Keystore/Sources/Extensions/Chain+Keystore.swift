import Foundation
import Primitives
import WalletCore
import WalletCorePrimitives

public extension Chain {
    func isValidAddress(_ address: String) -> Bool {
        return AnyAddress.isValid(string: address, coin: coinType)
    }
}


