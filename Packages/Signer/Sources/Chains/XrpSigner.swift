// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import WalletCore

internal import BigInt
internal import Formatters

struct XrpSigner: Signable {
    enum Operation {
        case operation(RippleSigningInput.OneOf_OperationOneof)
        case json(String)
    }
    
    func sign(input: SignerInput, operation: Operation, privateKey: Data) throws -> String {
        let signingInput = try RippleSigningInput.with {
            $0.fee = input.fee.fee.asInt64
            $0.sequence = UInt32(try input.metadata.getSequence())
            $0.lastLedgerSequence = UInt32(try input.metadata.getBlockNumber()) + 12
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
    
    func signTransfer(input: SignerInput, privateKey: Data) throws -> String {
        let operation: Operation = {
            if let memo = input.memo {
                if let destinationTag = UInt64(memo) {
                    return .operation(.opPayment(.with {
                        $0.destination = input.destinationAddress
                        $0.amount = input.value.asInt64
                        $0.destinationTag = destinationTag
                    }))
                } else if memo.isNotEmpty {
                    return .json(
                        jsonTransferMemo(
                            destination: input.destinationAddress,
                            amount: input.value.description,
                            memo: Data(memo.remove0x.utf8).hexString.remove0x
                        )
                    )
                }
            }
            return .operation(.opPayment(.with {
                $0.destination = input.destinationAddress
                $0.amount = input.value.asInt64
            }))
        }()
        
        return try sign(
            input: input,
            operation: operation,
            privateKey: privateKey
        )
    }
    
    func signTokenTransfer(input: SignerInput, privateKey: Data) throws -> String {
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
    
    func signAccountAction(input: SignerInput, privateKey: Data) throws -> String {
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
    
    private func hexSymbol(symbol: String) -> String {
        Data(symbol.utf8).hexString.capitalized.addTrailing(number: 40, padding: "0")
    }
    
    func signData(input: Primitives.SignerInput, privateKey: Data) throws -> String {
        fatalError()
    }
    
    func signStake(input: SignerInput, privateKey: Data) throws -> [String] {
        fatalError()
    }
    
    func signMessage(message: SignMessage, privateKey: Data) throws -> String {
        fatalError()
    }
    
    func jsonTransferMemo(destination: String, amount: String, memo: String) -> String {
        """
            {
                    "TransactionType": "Payment",
                    "Destination": "\(destination)",
                    "Amount": "\(amount)",
                    "Memos": [
                        {
                            "Memo": {
                                "MemoData": "\(memo)"
                            }
                        }
                    ]
                }
            """
    }
}
    
