// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import WalletCorePrimitives
import Keystore
import Primitives

public struct SolanaSigner: Signable {
    
    public func signTransfer(input: SignerInput, privateKey: Data) throws -> String {
        let coinType = input.coinType
        let type = SolanaSigningInput.OneOf_TransactionType.transferTransaction(.with {
            $0.recipient = input.destinationAddress
            $0.value = input.value.UInt
            $0.memo = input.memo.valueOrEmpty
        })
                                                                                
        return try sign(input: input, type: type, coinType: coinType, privateKey: privateKey)
    }
    
    public func signTokenTransfer(input: SignerInput, privateKey: Data) throws -> String {
        let coinType = input.coinType
        let decimals = UInt32(input.asset.decimals)
        let tokenId = try input.asset.getTokenId()
        let amount = input.value.UInt
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
                }
            )
            return try sign(input: input, type:  type, coinType: coinType, privateKey: privateKey)
        }
    }
    
    private func sign(input: SignerInput, type: SolanaSigningInput.OneOf_TransactionType, coinType: CoinType, privateKey: Data) throws -> String {
        let signingInput = SolanaSigningInput.with {
            $0.transactionType = type
            $0.recentBlockhash = input.block.hash
            $0.priorityFeeLimit = .with {
                $0.limit = UInt32(input.fee.gasLimit)
            }
            if input.fee.minerFee > 0 {
                $0.priorityFeePrice = .with {
                    $0.price = input.fee.minerFee.UInt
                }
            }
            $0.privateKey = privateKey
        }
        let output: SolanaSigningOutput = AnySigner.sign(input: signingInput, coin: coinType)
        return try transcodeBase58ToBase64(output.encoded)
    }
    
    public func signData(input: Primitives.SignerInput, privateKey: Data) throws -> String {
        guard case .generic(_, _, let extra) = input.type,
              let string = String(data: extra.data!, encoding: .utf8),
              let bytes = Base64.decode(string: string) else {
            throw AnyError("not data input")
        }
        return try signData(bytes: bytes, privateKey: privateKey)
    }
    
    func signData(bytes: Data, privateKey: Data) throws -> String {
        if bytes[0] != 1 {
            throw AnyError("only support one signature")
        }
        
        let message = bytes[65...]
        guard let signature = PrivateKey(data: privateKey)?.sign(digest: message, curve: .ed25519) else {
            throw AnyError("fail to sign data")
        }
        
        var signed = Data([0x1])
        signed.append(signature)
        signed.append(message)
        return signed.base64EncodedString()
    }
    
    public func swap(input: SignerInput, privateKey: Data) throws -> String {
        guard 
            case .swap(_, _, let action) = input.type,
            case .swap(_, let swapData) = action,
            let bytes = Base64.decode(string: swapData.data) else {
            throw AnyError("not swap SignerInput")
        }
        return try signData(bytes: bytes, privateKey: privateKey)
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
                $0.value = input.value.UInt
            })
        case .unstake(let delegation):
            transactionType = .deactivateStakeTransaction(.with {
                $0.stakeAccount = delegation.base.delegationId
            })
        case .withdraw(let delegation):
            transactionType = .withdrawTransaction(.with {
                $0.stakeAccount = delegation.base.delegationId
                $0.value = delegation.base.balanceValue.UInt
            })
        case .redelegate,
            .rewards:
            fatalError()
        }
        return [try sign(input: input, type: transactionType, coinType: input.coinType, privateKey: privateKey)]
    }
    
    private func transcodeBase58ToBase64(_ string: String) throws -> String {
        guard let data = Base58.decodeNoCheck(string: string) else {
            throw AnyError("string is not Base58 encoding!");
        }
        return data.base64EncodedString().paddded
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
