// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import class Gemstone.GemChainSigner
import class Gemstone.CryptoSigner
import GemstonePrimitives
import Primitives

import class Gemstone.GemChainSigner

final class ChainSigner: Signable {
    private let signer: GemChainSigner
    private let cryptoSigner = CryptoSigner()
    private let chain: Chain

    init(chain: Chain) {
        self.chain = chain
        signer = Gemstone.GemChainSigner(chain: chain.rawValue)
    }

    func signData(input: SignerInput, privateKey: Data) throws -> String {
        try signer.signData(input: input.map(), privateKey: privateKey)
    }

    func signTransfer(input: SignerInput, privateKey: Data) throws -> String {
        try signer.signTransfer(input: input.map(), privateKey: privateKey)
    }

    func signTokenTransfer(input: SignerInput, privateKey: Data) throws -> String {
        try signer.signTokenTransfer(input: input.map(), privateKey: privateKey)
    }

    func signNftTransfer(input: SignerInput, privateKey: Data) throws -> String {
        try signer.signNftTransfer(input: input.map(), privateKey: privateKey)
    }

    func signSwap(input: SignerInput, privateKey: Data) throws -> [String] {
        try signer.signSwap(input: input.map(), privateKey: privateKey)
    }

    func signTokenApproval(input: SignerInput, privateKey: Data) throws -> String {
        try signer.signTokenApproval(input: input.map(), privateKey: privateKey)
    }

    func signStake(input: SignerInput, privateKey: Data) throws -> [String] {
        try signer.signStake(input: input.map(), privateKey: privateKey)
    }

    func signAccountAction(input: SignerInput, privateKey: Data) throws -> String {
        try signer.signAccountAction(input: input.map(), privateKey: privateKey)
    }

    func signPerpetual(input: SignerInput, privateKey: Data) throws -> [String] {
        try signer.signPerpetual(input: input.map(), privateKey: privateKey)
    }

    func signWithdrawal(input: SignerInput, privateKey: Data) throws -> String {
        try signer.signWithdrawal(input: input.map(), privateKey: privateKey)
    }

    func signMessage(message: SignMessage, privateKey: Data) throws -> String {
        guard case .raw(let messageData) = message else {
            throw AnyError("Sui message signing expects raw message bytes")
        }

        switch chain.type {
        case .sui:
            return try cryptoSigner.signSuiPersonalMessage(message: messageData, privateKey: privateKey)
        default:
            throw AnyError("unimplemented: signMessage for chain \(chain.rawValue)")
        }
    }
}

