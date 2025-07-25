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
    
    private let ethereumSigner = EthereumSigner()
    
    public func signTransfer(input: SignerInput, privateKey: Data) throws -> String {
        try ethereumSigner.signTransfer(input: input, privateKey: privateKey)
    }
    
    public func signTokenTransfer(input: SignerInput, privateKey: Data) throws -> String {
        try ethereumSigner.signTokenTransfer(input: input, privateKey: privateKey)
    }
    
    public func signNftTransfer(input: SignerInput, privateKey: Data) throws -> String {
        try ethereumSigner.signNftTransfer(input: input, privateKey: privateKey)
    }
    
    public func signData(input: Primitives.SignerInput, privateKey: Data) throws -> String {
        try ethereumSigner.signData(input: input, privateKey: privateKey)
    }
    
    public func signSwap(input: SignerInput, privateKey: Data) throws -> [String] {
        try ethereumSigner.signSwap(input: input, privateKey: privateKey)
    }
    
    public func signTokenApproval(input: SignerInput, privateKey: Data) throws -> String {
        try ethereumSigner.signTokenApproval(input: input, privateKey: privateKey)
    }
    
    public func signStake(input: SignerInput, privateKey: Data) throws -> [String] {
        try ethereumSigner.signStake(input: input, privateKey: privateKey)
    }
    
    public func signMessage(message: SignMessage, privateKey: Data) throws -> String {
        try ethereumSigner.signMessage(message: message, privateKey: privateKey)
    }
    
    public func signAccountAction(input: SignerInput, privateKey: Data) throws -> String {
        throw AnyError("Account actions not supported on HyperCore")
    }
    
    public func signPerpetual(input: SignerInput, privateKey: Data) throws -> String {
        guard case .perpetual(_, _) = input.type else {
            throw AnyError("Invalid input type for perpetual signing")
        }
        
        // For now, use regular transfer signing as a placeholder
        // This will need proper implementation with specific perpetual contract calls
        return try ethereumSigner.signTransfer(input: input, privateKey: privateKey)
    }
}
