// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import class Gemstone.GemChainSigner
import GemstonePrimitives
import Primitives
import Gemstone

public final class SuiSigner: Signable {
    private let signer: GemChainSigner
    private let cryptoSigner = CryptoSigner()

    public init() {
        signer = Gemstone.GemChainSigner(chain: Chain.sui.rawValue)
    }

    public func signTransfer(input: SignerInput, privateKey: Data) throws -> String {
        try signer.signTransfer(input: input.map(), privateKey: privateKey)
    }

    public func signTokenTransfer(input: SignerInput, privateKey: Data) throws -> String {
        try signer.signTokenTransfer(input: input.map(), privateKey: privateKey)
    }

    public func signSwap(input: SignerInput, privateKey: Data) throws -> [String] {
        try signer.signSwap(input: input.map(), privateKey: privateKey)
    }

    public func signData(input: SignerInput, privateKey: Data) throws -> String {
        try signer.signData(input: input.map(), privateKey: privateKey)
    }

    public func signStake(input: SignerInput, privateKey: Data) throws -> [String] {
        try signer.signStake(input: input.map(), privateKey: privateKey)
    }

    public func signMessage(message: SignMessage, privateKey: Data) throws -> String {
        guard case .raw(let messageData) = message else {
            throw AnyError("Sui message signing expects raw message bytes")
        }
        return try cryptoSigner.signSuiPersonalMessage(message: messageData, privateKey: privateKey)
    }
}
