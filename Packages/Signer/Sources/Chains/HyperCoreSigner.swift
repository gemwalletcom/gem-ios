// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import class Gemstone.GemChainSigner
import GemstonePrimitives
import Primitives

public class HyperCoreSigner: Signable {
    private let signer: GemChainSigner

    public init() {
        signer = Gemstone.GemChainSigner(chain: Chain.hyperCore.rawValue)
    }

    public func signData(input: Primitives.SignerInput, privateKey: Data) throws -> String {
        try signer.signData(input: input.map(), privateKey: privateKey)
    }

    public func signTransfer(input: Primitives.SignerInput, privateKey: Data) throws -> String {
        try signer.signTransfer(input: input.map(), privateKey: privateKey)
    }

    public func signTokenTransfer(input: Primitives.SignerInput, privateKey: Data) throws -> String {
        try signer.signTokenTransfer(input: input.map(), privateKey: privateKey)
    }

    public func signNftTransfer(input: Primitives.SignerInput, privateKey: Data) throws -> String {
        try signer.signNftTransfer(input: input.map(), privateKey: privateKey)
    }

    public func signSwap(input: Primitives.SignerInput, privateKey: Data) throws -> [String] {
        try signer.signSwap(input: input.map(), privateKey: privateKey)
    }

    public func signTokenApproval(input: Primitives.SignerInput, privateKey: Data) throws -> String {
        try signer.signTokenApproval(input: input.map(), privateKey: privateKey)
    }

    public func signStake(input: Primitives.SignerInput, privateKey: Data) throws -> [String] {
        try signer.signStake(input: input.map(), privateKey: privateKey)
    }

    public func signAccountAction(input: Primitives.SignerInput, privateKey: Data) throws -> String {
        try signer.signAccountAction(input: input.map(), privateKey: privateKey)
    }

    public func signPerpetual(input: Primitives.SignerInput, privateKey: Data) throws -> [String] {
        try signer.signPerpetual(input: input.map(), privateKey: privateKey)
    }

    public func signWithdrawal(input: Primitives.SignerInput, privateKey: Data) throws -> String {
        try signer.signWithdrawal(input: input.map(), privateKey: privateKey)
    }
}
