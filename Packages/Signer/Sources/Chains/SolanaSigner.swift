// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keystore
import Primitives
import WalletCore

internal import Gemstone
internal import BigInt

struct SolanaSigner: Signable {
    func signTransfer(input: SignerInput, privateKey: Data) throws -> String {
        let coinType = input.coinType
        let type = SolanaSigningInput.OneOf_TransactionType.transferTransaction(.with {
            $0.recipient = input.destinationAddress
            $0.value = input.value.asUInt
            $0.memo = input.memo.valueOrEmpty
        })

        return try sign(input: input, type: type, coinType: coinType, privateKey: privateKey)
    }

    func signTokenTransfer(input: SignerInput, privateKey: Data) throws -> String {
        let coinType = input.coinType
        let decimals = UInt32(input.asset.decimals)
        let tokenId = try input.asset.getTokenId()
        let amount = input.value.asUInt
        let destinationAddress = input.destinationAddress

        guard case .solana(let senderTokenAddress, let recipientTokenAddress, let solanaTokenProgram, _) = input.metadata,
              let token = solanaTokenProgram, let senderTokenAddress = senderTokenAddress
        else {
            throw AnyError("unknown solana metadata")
        }

        switch recipientTokenAddress {
        case .some(let recipientTokenAddress):
            let type = SolanaSigningInput.OneOf_TransactionType.tokenTransferTransaction(.with {
                $0.amount = amount
                $0.decimals = decimals
                $0.tokenMintAddress = tokenId
                $0.senderTokenAddress = senderTokenAddress
                $0.recipientTokenAddress = recipientTokenAddress
                $0.memo = input.memo.valueOrEmpty
                $0.tokenProgramID = token.program
            })
            return try sign(input: input, type: type, coinType: coinType, privateKey: privateKey)
        case .none:
            let walletAddress = SolanaAddress(string: destinationAddress)!
            let calculatedRecipientTokenAddress = switch token {
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
                $0.senderTokenAddress = senderTokenAddress
                $0.recipientTokenAddress = calculatedRecipientTokenAddress
                $0.memo = input.memo.valueOrEmpty
                $0.tokenProgramID = token.program
            })
            return try sign(input: input, type: type, coinType: coinType, privateKey: privateKey)
        }
    }

    func signNftTransfer(input: SignerInput, privateKey: Data) throws -> String {
        throw AnyError.notImplemented
    }

    private func sign(input: SignerInput, type: SolanaSigningInput.OneOf_TransactionType, coinType: CoinType, privateKey: Data) throws -> String {
        let unitPrice = input.fee.gasPriceType.unitPrice
        let jitoTip = input.fee.gasPriceType.jitoTip

        let signingInput = try SolanaSigningInput.with {
            $0.transactionType = type
            $0.recentBlockhash = try input.metadata.getBlockHash()
            $0.priorityFeeLimit = .with {
                $0.limit = UInt32(input.fee.gasLimit)
            }
            if unitPrice > 0 {
                $0.priorityFeePrice = .with {
                    $0.price = UInt64(unitPrice)
                }
            }
            $0.privateKey = privateKey
        }
        let output: SolanaSigningOutput = AnySigner.sign(input: signingInput, coin: coinType)

        if !output.errorMessage.isEmpty {
            throw AnyError(output.errorMessage)
        }

        let encoded = try transcodeBase58ToBase64(output.encoded)
        if jitoTip > 0 {
            let instructionJson = Gemstone.solanaCreateJitoTipInstruction(from: input.senderAddress, lamports: jitoTip)
            guard let transaction = SolanaTransaction.insertInstruction(encodedTx: encoded, insertAt: -1, instruction: instructionJson) else {
                throw AnyError("unable to insert Jito tip instruction")
            }
            return try signRawTransaction(transaction: transaction, privateKey: privateKey)
        }
        return try signRawTransaction(transaction: encoded, privateKey: privateKey)
    }

    func signData(input: Primitives.SignerInput, privateKey: Data) throws -> String {
        guard
            case .generic(_, _, let extra) = input.type,
            let string = String(data: extra.data!, encoding: .utf8),
            let bytes = Base64.decode(string: string)
        else {
            throw AnyError("not data input")
        }
        return try signData(bytes: bytes, privateKey: privateKey, outputType: extra.outputType)
    }

    func signData(bytes: Data, privateKey: Data, outputType: Primitives.TransferDataOutputType) throws -> String {
        let rawTxDecoder = SolanaRawTxDecoder(rawData: bytes)
        let numRequiredSignatures = rawTxDecoder.signatureCount()
        var signatures: [Data] = rawTxDecoder.signatures()

        guard signatures[0] == Data(repeating: 0x0, count: 64) else {
            throw AnyError("user signature should be first")
        }

        // read message to sign
        let message = rawTxDecoder.messageData()
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

    func signRawTransaction(transaction: String, privateKey: Data) throws -> String {
        guard let transactionData = Base64.decode(string: transaction) else {
            throw AnyError("unable to decode base64 string")
        }
        let decodeOutputData = TransactionDecoder.decode(coinType: .solana, encodedTx: transactionData)
        let decodeOutput = try SolanaDecodingTransactionOutput(serializedBytes: decodeOutputData)

        let signingInput = SolanaSigningInput.with {
            $0.privateKey = privateKey
            $0.rawMessage = decodeOutput.transaction
            $0.txEncoding = .base64
        }
        let output: SolanaSigningOutput = AnySigner.sign(input: signingInput, coin: .solana)

        if !output.errorMessage.isEmpty {
            throw AnyError(output.errorMessage)
        }
        return output.encoded
    }

    func signSwap(input: SignerInput, privateKey: Data) throws -> [String] {
        let (_, _, data) = try input.type.swap()
        let encodedTx = data.data.data
        let unitPrice = input.fee.gasPriceType.unitPrice
        let unitLimit = input.fee.gasLimit
        let jitoTip = input.fee.gasPriceType.jitoTip

        guard
            let encodedTxData = Base64.decode(string: encodedTx),
            !encodedTxData.isEmpty
        else {
            throw AnyError("unable to decode base64 string or empty transaction data")
        }

        let rawTxDecoder = SolanaRawTxDecoder(rawData: encodedTxData)
        let numRequiredSignatures = rawTxDecoder.signatureCount()
        if numRequiredSignatures > 1 {
            // other signers' signatures already prefilled, changing instructions would lead signature verification failure
            return try [
                signRawTransaction(transaction: encodedTx, privateKey: privateKey),
            ]
        }

        var finalTransaction = encodedTx
        if unitPrice > 0 {
            let currentUnitPrice = SolanaTransaction.getComputeUnitPrice(encodedTx: finalTransaction).flatMap(UInt64.init)
            let targetUnitPrice = UInt64(unitPrice)
            if currentUnitPrice.map({ targetUnitPrice > $0 }) ?? true {
                guard let tx = SolanaTransaction.setComputeUnitPrice(encodedTx: finalTransaction, price: String(targetUnitPrice)) else {
                    throw AnyError("unable to set compute unit price")
                }
                finalTransaction = tx
            }
        }

        if unitLimit > 0 {
            let currentUnitLimit = SolanaTransaction.getComputeUnitLimit(encodedTx: finalTransaction).flatMap(UInt64.init)
            let targetUnitLimit = UInt64(unitLimit)
            if currentUnitLimit.map({ targetUnitLimit > $0 }) ?? true {
                guard let tx = SolanaTransaction.setComputeUnitLimit(encodedTx: finalTransaction, limit: String(targetUnitLimit)) else {
                    throw AnyError("unable to set compute unit limit")
                }
                finalTransaction = tx
            }
        }

        if jitoTip > 0 {
            let instructionJson = Gemstone.solanaCreateJitoTipInstruction(from: input.senderAddress, lamports: jitoTip)
            guard let tx = SolanaTransaction.insertInstruction(encodedTx: finalTransaction, insertAt: -1, instruction: instructionJson) else {
                throw AnyError("unable to insert Jito tip instruction")
            }
            finalTransaction = tx
        }

        return try [
            signRawTransaction(transaction: finalTransaction, privateKey: privateKey),
        ]
    }

    func signStake(input: SignerInput, privateKey: Data) throws -> [String] {
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
            let encoded = try sign(input: input, type: transactionType, coinType: input.coinType, privateKey: privateKey)
            let memo = input.memo ?? ""
            let instruction = try SolanaInstruction(
                programId: "MemoSq4gqABAXKb96qnH8TysNcWxMyWCqXgDLGmfcHr",
                accounts: [
                    SolanaAccountMeta(pubkey: input.senderAddress, isSigner: true, isWritable: true),
                ],
                data: Base58.encodeNoCheck(data: memo.encodedData())
            )
            let data = try JSONEncoder().encode(instruction)
            let instructionJson = try data.encodeString()
            guard let transaction = SolanaTransaction.insertInstruction(encodedTx: encoded, insertAt: -1, instruction: instructionJson) else {
                throw AnyError("Unable to add instruction")
            }
            return try [
                signRawTransaction(transaction: transaction, privateKey: privateKey),
            ]
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
        case .freeze:
            throw AnyError("Solana does not support freeze operations")
        }
        return try [
            sign(input: input, type: transactionType, coinType: input.coinType, privateKey: privateKey),
        ]
    }

    private func transcodeBase58ToBase64(_ string: String) throws -> String {
        return try Base58.decodeNoCheck(string: string)
            .base64EncodedString()
            .paddded
    }
}

extension String {
    var paddded: Self {
        let offset = count % 4
        guard offset != 0 else { return self }
        return padding(toLength: count + 4 - offset, withPad: "=", startingAt: 0)
    }
}

struct SolanaRawTxDecoder {
    let rawData: Data

    /// Decode a “short-vec” (compact-U16) length at `offset`, advancing the offset.
    private func decodeShortVecLength(offset: inout Int) -> UInt8 {
        let byte = rawData[offset]
        offset += 1
        return byte & 0x7F
    }

    func signatureCount() -> UInt8 {
        var offset = 0
        return decodeShortVecLength(offset: &offset)
    }

    func signatures() -> [Data] {
        var offset = 0
        let count = decodeShortVecLength(offset: &offset)
        var result: [Data] = []
        for _ in 0..<count {
            let sig = rawData.subdata(in: offset..<(offset + 64))
            result.append(sig)
            offset += 64
        }
        return result
    }

    /// The serialized message bytes that every signer signs.
    /// (Everything after the sig-array: length byte + N×64-byte sigs.)
    func messageData() -> Data {
        var offset = 0
        let sigCount = Int(decodeShortVecLength(offset: &offset))
        offset += sigCount * 64
        return rawData.subdata(in: offset..<rawData.count)
    }
}
