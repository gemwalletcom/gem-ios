// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import Keystore
import Primitives

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
        return signTxDataDigest(data: try input.metadata.getMessageBytes(), privateKey: privateKey)
    }
    
    func signMessageBytes(coinType: CoinType, bytes: String, privateKey: Data) -> String {
        let signingInput = SuiSigningInput.with {
            $0.transactionPayload = .signDirectMessage(SuiSignDirect.with {
                $0.unsignedTxMsg = bytes
            })
            $0.privateKey = privateKey
        }
        
        let output: SuiSigningOutput = AnySigner.sign(input: signingInput, coin: coinType)
        return bytes + "_" + output.signature
    }
    
    func signTxDataDigest(data: String, privateKey: Data) -> String {
        let key = PrivateKey(data: privateKey)!
        let pubKey = key.getPublicKeyEd25519()
        
        let parts = data.split(separator: "_").map { String($0) }
        let digest = Data(hexString: parts[1])!
        let signature = key.sign(digest: digest, curve: .ed25519)!
        
        var sig = Data([0x0])
        sig.append(signature)
        sig.append(pubKey.data)
        return parts[0] + "_" + sig.base64EncodedString()
    }
}
