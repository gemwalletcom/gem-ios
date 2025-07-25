// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import WalletCorePrimitives
import BigInt
import Keystore
import Primitives
import Blockchain
import GemstonePrimitives

public class HyperCoreSigner: Signable {
    
    public func signTransfer(input: SignerInput, privateKey: Data) throws -> String {
        fatalError()
    }
    
    public func signPerpetual(input: SignerInput, privateKey: Data) throws -> String {
        guard case .perpetual(let asset, let type) = input.type else {
            throw AnyError("Invalid input type for perpetual signing")
        }
        
        NSLog("asset \(asset), type \(type)")
        
        fatalError()
    }
}
