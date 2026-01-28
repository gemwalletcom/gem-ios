// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

internal import class Gemstone.GemChainSigner
internal import GemstonePrimitives

final class ChainSigner: Signable {
    private let signer: GemChainSigner
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
        let messageData: Data
        switch message {
        case .typed(let typed):
            guard let data = typed.data(using: .utf8) else {
                throw AnyError("Typed message is not valid UTF-8")
            }
            messageData = data
        case .raw(let data):
            messageData = data
        }

        return try signer.signMessage(message: messageData, privateKey: privateKey)
    }
}
