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
            $0.sequence = Int32(input.sequence)
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
                if let memo = input.memo, let destinationTag = Int64(memo) {
                    $0.destinationTag = destinationTag
                }
            }),
            privateKey: privateKey
        )
    }
    
    public func signAccountAction(input: SignerInput, privateKey: Data) throws -> String {
        let tokenId = try input.asset.getTokenId()
        let hexTokenId = Data(input.asset.symbol.utf8).hexString.capitalized
        //Wallet Core does not support non native codes:
        //https://github.com/trustwallet/wallet-core/blob/7b1bee59813f2d93e15e20c8e331cb0b1fafc51b/src/XRP/Transaction.cpp#L267
        
        return try sign(
            input: input,
            operation: .opTrustSet(RippleOperationTrustSet.with {
                $0.limitAmount = RippleCurrencyAmount.with {
                    $0.issuer = tokenId
                    $0.currency = hexTokenId.addTrailing(number: 40, padding: "0")
                    $0.value = "690000000"
                }
            }),
            privateKey: privateKey
        )
    }
    
    public func signTokenTransfer(input: SignerInput, privateKey: Data) throws -> String {
        fatalError()
    }
    
    public func signData(input: Primitives.SignerInput, privateKey: Data) throws -> String {
        fatalError()
    }
    
    public func swap(input: SignerInput, privateKey: Data) throws -> String {
        fatalError()
    }
    
    public func signStake(input: SignerInput, privateKey: Data) throws -> [String] {
        fatalError()
    }
    
    public func signMessage(message: SignMessage, privateKey: Data) throws -> String {
        fatalError()
    }
}
    
