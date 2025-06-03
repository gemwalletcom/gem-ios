// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import WalletCorePrimitives
import Blockchain
import Primitives
import BigInt

public struct XrpSigner: Signable {
    enum Operation {
        case operation(RippleSigningInput.OneOf_OperationOneof)
        case json(String)
    }
    
    func sign(input: SignerInput, operation: Operation, privateKey: Data) throws -> String {
        let signingInput = RippleSigningInput.with {
            $0.fee = input.fee.fee.asInt64
            $0.sequence = input.sequence.asUInt32
            $0.lastLedgerSequence = (input.block.number + 12).asUInt32
            $0.account = input.senderAddress
            $0.privateKey = privateKey
            switch operation {
            case .operation(let operation):
                $0.operationOneof = operation
            case .json(let rawJson):
                $0.rawJson = rawJson
            }
            
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
            operation: .operation(.opPayment(RippleOperationPayment.with {
                $0.destination = input.destinationAddress
                $0.amount = input.value.asInt64
                if let memo = input.memo, let destinationTag = UInt64(memo) {
                    $0.destinationTag = destinationTag
                }
            })),
            privateKey: privateKey
        )
    }
    
    public func signTokenTransfer(input: SignerInput, privateKey: Data) throws -> String {
        return try sign(
            input: input,
            operation: .operation(.opPayment(.with {
                $0.destination = input.destinationAddress
                $0.currencyAmount = try .with {
                    $0.issuer = try input.asset.getTokenId()
                    $0.currency = hexSymbol(symbol: input.asset.symbol)
                    $0.value = ValueFormatter.full.string(input.value, decimals: input.asset.decimals.asInt)
                }
                if let memo = input.memo, let destinationTag = UInt64(memo) {
                    $0.destinationTag = destinationTag
                }
            })),
            privateKey: privateKey
        )
    }
    
    public func signAccountAction(input: SignerInput, privateKey: Data) throws -> String {
        return try sign(
            input: input,
            operation: .operation(.opTrustSet(.with {
                $0.limitAmount = try .with {
                    $0.issuer = try input.asset.getTokenId()
                    $0.currency = hexSymbol(symbol: input.asset.symbol)
                    $0.value = "690000000000"
                }
            })),
            privateKey: privateKey
        )
    }
    
    public func hexSymbol(symbol: String) -> String {
        Data(symbol.utf8).hexString.capitalized.addTrailing(number: 40, padding: "0")
    }
    
    public func signData(input: Primitives.SignerInput, privateKey: Data) throws -> String {
        fatalError()
    }
    
    public func signSwap(input: SignerInput, privateKey: Data) throws -> [String] {
        let (_, _, quote, swapData) = try input.type.swap()
        
        switch quote.data.provider.id {
        case .thorchain:
            let json = """
                {
                        "TransactionType": "Payment",
                        "Destination": "\(swapData.to)",
                        "Amount": "\(swapData.value)",
                        "Memos": [
                            {
                                "Memo": {
                                    "MemoData": "\(swapData.data.remove0x)"
                                }
                            }
                        ]
                    }
                """
        
            return [
                try sign(
                    input: input,
                    operation: .json(json),
                    privateKey: privateKey
                )
            ]
        default: fatalError()
        }
    }
    
    public func signStake(input: SignerInput, privateKey: Data) throws -> [String] {
        fatalError()
    }
    
    public func signMessage(message: SignMessage, privateKey: Data) throws -> String {
        fatalError()
    }
}
    
