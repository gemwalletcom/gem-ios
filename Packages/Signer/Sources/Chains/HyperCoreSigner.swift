// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import BigInt
import Keystore
import Primitives
import GemstonePrimitives

public class HyperCoreSigner: Signable {
    
    public func signTransfer(input: SignerInput, privateKey: Data) throws -> String {
        fatalError()
    }
    
    public func signPerpetual(input: SignerInput, privateKey: Data) throws -> String {
        guard case .perpetual(let asset, let type) = input.type else {
            throw AnyError("Invalid input type for perpetual signing")
        }
        
        switch type {
        case .close: break
        case .open(let direction):
            switch direction {
            case .long: break
            case .short: break
            }
        }
        
        NSLog("asset \(asset), type \(type)")
        
        fatalError()
    }
}
