// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import WalletCorePrimitives
import Blockchain
import Primitives
import BigInt

public struct XrpSigner: Signable {
    
    func sign(input: SignerInput, operation: RippleSigningInput.OneOf_OperationOneof, privateKey: Data) throws -> String {
        let signingInput = RippleSigningInput.with {
            $0.fee = input.fee.fee.asInt64
            $0.sequence = input.sequence.asUInt32
            $0.lastLedgerSequence = (input.block.number + 10).asUInt32
            $0.account = input.senderAddress
            $0.privateKey = privateKey
            $0.operationOneof = operation
        }
        let output: RippleSigningOutput = AnySigner.sign(input: signingInput, coin: input.coinType)
        
        if !output.errorMessage.isEmpty {
            throw AnyError(output.errorMessage)
        }
        
        return output.encoded.hexString
    }
    
    public func signTransfer(input: SignerInput, privateKey: Data) throws -> String {
        try sign(
            input: input,
            operation: .opPayment(RippleOperationPayment.with {
                $0.destination = input.destinationAddress
                $0.amount = input.value.asInt64
                if let memo = input.memo, let destinationTag = UInt32(memo) {
                    $0.destinationTag = destinationTag
                }
            }),
            privateKey: privateKey
        )
    }
    
    public func signAccountAction(input: SignerInput, privateKey: Data) throws -> String {
        let (issuer, symbol) = try input.asset.id.twoSubTokenIds()
        return try sign(
            input: input,
            operation: .opTrustSet(.with {
                $0.limitAmount = .with {
                    $0.issuer = issuer
                    $0.currency = hexSymbol(symbol: symbol)
                    $0.value = "690000000000"
                }
            }),
            privateKey: privateKey
        )
    }
    
    public func hexSymbol(symbol: String) -> String {
        Data(symbol.utf8).hexString.capitalized.addTrailing(number: 40, padding: "0")
    }
    
    public func signTokenTransfer(input: SignerInput, privateKey: Data) throws -> String {
        let (issuer, symbol) = try input.asset.id.twoSubTokenIds()
        return try sign(
            input: input,
            operation: .opPayment(.with {
                $0.destination = input.destinationAddress
                $0.currencyAmount = .with {
                    $0.issuer = issuer
                    $0.currency = hexSymbol(symbol: symbol)
                    $0.value = ValueFormatter.full.string(input.value, decimals: 15)
                }
                if let memo = input.memo, let destinationTag = UInt32(memo) {
                    $0.destinationTag = destinationTag
                }
            }),
            privateKey: privateKey
        )
    }
    
    public func signData(input: Primitives.SignerInput, privateKey: Data) throws -> String {
        fatalError()
    }
    
    public func signSwap(input: SignerInput, privateKey: Data) throws -> [String] {
        fatalError()
    }
    
    public func signStake(input: SignerInput, privateKey: Data) throws -> [String] {
        fatalError()
    }
    
    public func signMessage(message: SignMessage, privateKey: Data) throws -> String {
        fatalError()
    }
}
    
