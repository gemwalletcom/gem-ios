// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import WalletCorePrimitives
import Keystore
import Primitives
import BigInt

public struct SolanaSigner: Signable {
    
    public func signTransfer(input: SignerInput, privateKey: Data) throws -> String {
        let coinType = input.coinType
        let type = SolanaSigningInput.OneOf_TransactionType.transferTransaction(.with {
            $0.recipient = input.destinationAddress
            $0.value = input.value.asUInt
            $0.memo = input.memo.valueOrEmpty
        })
                                                                                
        return try sign(input: input, type: type, coinType: coinType, privateKey: privateKey)
    }
    
    public func signTokenTransfer(input: SignerInput, privateKey: Data) throws -> String {
        let coinType = input.coinType
        let decimals = UInt32(input.asset.decimals)
        let tokenId = try input.asset.getTokenId()
        let amount = input.value.asUInt
        let destinationAddress = input.destinationAddress
        let tokenProgram: WalletCore.SolanaTokenProgramId = switch input.token.tokenProgram {
        case .token: .tokenProgram
        case .token2022: .token2022Program
        }
        switch input.token.recipientTokenAddress {
        case .some(let recipientTokenAddress):
            let type = SolanaSigningInput.OneOf_TransactionType.tokenTransferTransaction(.with {
                $0.amount = amount
                $0.decimals = decimals
                $0.tokenMintAddress = tokenId
                $0.senderTokenAddress = input.token.senderTokenAddress
                $0.recipientTokenAddress = recipientTokenAddress
                $0.memo = input.memo.valueOrEmpty
                $0.tokenProgramID = tokenProgram
            })
            return try sign(input: input, type:  type, coinType: coinType, privateKey: privateKey)
        case .none:
            let walletAddress = SolanaAddress(string: destinationAddress)!
            let recipientTokenAddress = switch input.token.tokenProgram {
            case .token:
                walletAddress.defaultTokenAddress(tokenMintAddress: tokenId)!
            case .token2022:
                walletAddress.token2022Address(tokenMintAddress: tokenId)!
            }
            let type = SolanaSigningInput.OneOf_TransactionType.createAndTransferTokenTransaction(.with {
                $0.amount = amount
                $0.decimals = decimals
                $0.recipientMainAddress = destinationAddress
                $0.tokenMintAddress = tokenId
                $0.senderTokenAddress = input.token.senderTokenAddress
                $0.recipientTokenAddress = recipientTokenAddress
                $0.memo = input.memo.valueOrEmpty
                $0.tokenProgramID = tokenProgram
            })
            return try sign(input: input, type:  type, coinType: coinType, privateKey: privateKey)
        }
    }
    
    public func signNftTransfer(input: SignerInput, privateKey: Data) throws -> String {
        fatalError()
    }
    
    private func sign(input: SignerInput, type: SolanaSigningInput.OneOf_TransactionType, coinType: CoinType, privateKey: Data) throws -> String {
        let signingInput = SolanaSigningInput.with {
            $0.transactionType = type
            $0.recentBlockhash = input.block.hash
            $0.priorityFeeLimit = .with {
                $0.limit = UInt32(input.fee.gasLimit)
            }
            if input.fee.priorityFee > 0 {
                $0.priorityFeePrice = .with {
                    $0.price = input.fee.priorityFee.asUInt
                }
            }
            $0.privateKey = privateKey
        }
        let output: SolanaSigningOutput = AnySigner.sign(input: signingInput, coin: coinType)
        
        if !output.errorMessage.isEmpty {
            throw AnyError(output.errorMessage)
        }
        
        return try transcodeBase58ToBase64(output.encoded)
    }
    
    public func signData(input: Primitives.SignerInput, privateKey: Data) throws -> String {
        guard
            case .generic(_, _, let extra) = input.type,
            let string = String(data: extra.data!, encoding: .utf8),
            let bytes = Base64.decode(string: string)
        else {
            throw AnyError("not data input")
        }
        return try signData(bytes: bytes, privateKey: privateKey, outputType: extra.outputType)
    }
    
    func signData(bytes: Data, privateKey: Data, outputType: TransferDataExtra.OutputType) throws -> String {
        var offset = 0
        // read number of signature neede
        let numRequiredSignatures = bytes[offset]
        offset = 1

        // read all the signatures
        var signatures: [Data] = []
        for _ in 0..<Int(numRequiredSignatures) {
            signatures.append(Data(bytes[offset..<offset+64]))
            offset += 64
        }

        assert(offset == 1 + 64 * numRequiredSignatures)
        guard signatures[0] == Data(repeating: 0x0, count: 64) else {
            throw AnyError("user signature should be first")
        }

        // read message to sign
        let message = bytes[offset...]
        guard
            let signature = PrivateKey(data: privateKey)?.sign(digest: message, curve: .ed25519)
        else {
            throw AnyError("fail to sign data")
        }

        switch outputType {
        case .signature:
            return Base58.encodeNoCheck(data: signature)
        case .encodedTransaction:
            // update user's signature
            signatures[0] = signature

            var signed = Data([numRequiredSignatures])
            for sig in signatures {
                signed.append(sig)
            }
            signed.append(message)
            return signed.base64EncodedString()
        }
    }
    
    public func signSwap(input: SignerInput, privateKey: Data) throws -> [String] {
        guard 
            case .swap(_, _, _, let swapData) = input.type else {
            throw AnyError("not swap SignerInput")
        }
        let price = input.fee.priorityFee
        let limit = input.fee.gasLimit
        
        guard let transaction = SolanaTransaction.setComputeUnitPrice(encodedTx: swapData.data, price: price.description) else {
            throw AnyError("Unable to set compute unit price")
        }
        guard let transaction = SolanaTransaction.setComputeUnitLimit(encodedTx: transaction, limit: limit.description) else {
            throw AnyError("Unable to set compute unit limit")
        }
        guard let transactionData = Base64.decode(string: transaction) else {
            throw AnyError("not swap SignerInput")
        }
        let decodeOutputData = TransactionDecoder.decode(coinType: .solana, encodedTx: transactionData)
        let decodeOutput = try SolanaDecodingTransactionOutput(serializedData: decodeOutputData)
        
        let signingInput = SolanaSigningInput.with {
            $0.privateKey = privateKey
            $0.rawMessage = decodeOutput.transaction
            $0.txEncoding = .base64
        }
        let output: SolanaSigningOutput = AnySigner.sign(input: signingInput, coin: .solana)
        
        if !output.errorMessage.isEmpty {
            throw AnyError(output.errorMessage)
        }
        
        return [output.encoded]
    }
    
    public func signStake(input: SignerInput, privateKey: Data) throws -> [String] {
        guard case .stake(_, let type) = input.type else {
            throw AnyError("invalid type")
        }
        let transactionType: SolanaSigningInput.OneOf_TransactionType
        switch type {
        case .stake(let validator):
            transactionType = .delegateStakeTransaction(.with {
                $0.validatorPubkey = validator.id
                $0.value = input.value.asUInt
            })
        case .unstake(let delegation):
            transactionType = .deactivateStakeTransaction(.with {
                $0.stakeAccount = delegation.base.delegationId
            })
        case .withdraw(let delegation):
            transactionType = .withdrawTransaction(.with {
                $0.stakeAccount = delegation.base.delegationId
                $0.value = delegation.base.balanceValue.asUInt
            })
        case .redelegate,
            .rewards:
            fatalError()
        }
        return [
            try sign(input: input, type: transactionType, coinType: input.coinType, privateKey: privateKey),
        ]
    }
    
    private func transcodeBase58ToBase64(_ string: String) throws -> String {
        return try Base58.decodeNoCheck(string: string)
            .base64EncodedString()
            .paddded
    }
    
    public func signMessage(message: SignMessage, privateKey: Data) throws -> String {
        fatalError()
    }
}

extension String {
  var paddded: Self {
    let offset = count % 4
    guard offset != 0 else { return self }
    return padding(toLength: count + 4 - offset, withPad: "=", startingAt: 0)
  }
}
