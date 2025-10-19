// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keystore
import Primitives
import Gemstone

public struct SuiSigner: Signable {
    public func signTransfer(input: SignerInput, privateKey: Data) throws -> String {
        try sign(input: input, privateKey: privateKey)
    }
    
    public func signTokenTransfer(input: SignerInput, privateKey: Data) throws -> String {
        try sign(input: input, privateKey: privateKey)
    }
    
    public func signSwap(input: SignerInput, privateKey: Data) throws -> [String] {
        [try sign(input: input, privateKey: privateKey)]
    }
    
    public func signData(input: SignerInput, privateKey: Data) throws -> String {
        try signTxDataDigest(data: try input.metadata.getMessageBytes(), privateKey: privateKey)
    }
    
    public func signStake(input: SignerInput, privateKey: Data) throws -> [String] {
        guard case .stake(_, let type) = input.type else {
            throw AnyError.notImplemented
        }
        switch type {
        case .stake, .unstake:
            return [try sign(input: input, privateKey: privateKey)]
        case .redelegate, .rewards, .withdraw:
            throw AnyError.notImplemented
        case .freeze:
            throw AnyError("Sui does not support freeze operations")
        }
    }
    
    func sign(input: SignerInput, privateKey: Data) throws -> String {
        return try signTxDataDigest(data: try input.metadata.getMessageBytes(), privateKey: privateKey)
    }
    
    public func signMessage(message: SignMessage, privateKey: Data) throws -> String {
        guard case .raw(let messageData) = message else {
            throw AnyError("Sui message signing expects raw message bytes")
        }
        let signer = GemstoneSigner()
        return try signer.signSuiPersonalMessage(message: messageData, privateKey: privateKey)
    }
    
    func signTxDataDigest(data: String, privateKey: Data) throws -> String {
        let parts = data.split(separator: "_").map { String($0) }
        guard parts.count == 2 else {
            throw AnyError("Invalid Sui digest payload")
        }
        guard let digest = Data(hexString: parts[1]) else {
            throw AnyError("Invalid digest hex for Sui transaction")
        }
        let signer = GemstoneSigner()
        let signature = try signer.signSuiDigest(digest: digest, privateKey: privateKey)
        return parts[0] + "_" + signature
    }
}
