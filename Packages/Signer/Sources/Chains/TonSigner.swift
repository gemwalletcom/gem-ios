// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import WalletCorePrimitives
import Keystore
import Primitives

public struct TonSigner: Signable {
    public func signTransfer(input: SignerInput, privateKey: Data) throws -> String {
        let transfer = TheOpenNetworkTransfer.with {
            $0.walletVersion = TheOpenNetworkWalletVersion.walletV4R2
            $0.dest = input.destinationAddress
            $0.amount = input.value.UInt
            if let memo = input.memo {
                $0.comment = memo
            }
            $0.mode = UInt32(TheOpenNetworkSendMode.payFeesSeparately.rawValue | TheOpenNetworkSendMode.ignoreActionPhaseErrors.rawValue)
            $0.bounceable = false
        }

        let signingInput = TheOpenNetworkSigningInput.with {
            $0.sequenceNumber = UInt32(input.sequence)
            $0.expireAt = expireAt()
            $0.messages = [transfer]
            $0.privateKey = privateKey
        }
        return try sign(input: signingInput, coinType: input.coinType)
    }

    public func signTokenTransfer(input: SignerInput, privateKey: Data) throws -> String {
        guard let jettonCreationFee = input.fee.options[.tokenAccountCreation] else {
            throw AnyError("Invalid token creation fee")
        }

        let jettonTransfer = TheOpenNetworkJettonTransfer.with {
            $0.jettonAmount = input.value.UInt
            $0.toOwner = input.destinationAddress
            $0.responseAddress = input.senderAddress
            $0.forwardAmount = 1
        }

        let transfer = TheOpenNetworkTransfer.with {
            $0.walletVersion = TheOpenNetworkWalletVersion.walletV4R2
            $0.dest = input.token.senderTokenAddress // My Jetton Wallet address
            $0.amount = jettonCreationFee.UInt
            if let memo = input.memo {
                $0.comment = memo
            }
            $0.mode = UInt32(TheOpenNetworkSendMode.payFeesSeparately.rawValue | TheOpenNetworkSendMode.ignoreActionPhaseErrors.rawValue)
            $0.bounceable = true
            $0.jettonTransfer = jettonTransfer
        }

        let signingInput = TheOpenNetworkSigningInput.with {
            $0.sequenceNumber = UInt32(input.sequence)
            $0.expireAt = expireAt()
            $0.messages = [transfer]
            $0.privateKey = privateKey
        }
        
        return try sign(input: signingInput, coinType: input.coinType)
    }

    private func sign(input: TheOpenNetworkSigningInput, coinType: CoinType) throws -> String {
        let output = (AnySigner.sign(input: input, coin: coinType) as TheOpenNetworkSigningOutput)

        if !output.errorMessage.isEmpty {
            throw AnyError(output.errorMessage)
        }

        return output.encoded
    }

    private func expireAt() -> UInt32 {
        UInt32(Date.now.timeIntervalSince1970 + TimeInterval(600))
    }

    public func signData(input: Primitives.SignerInput, privateKey: Data) throws -> String {
        fatalError()
    }
    
    public func swap(input: SignerInput, privateKey: Data) throws -> String {
        fatalError()
    }
    
    public func signStake(input: SignerInput, privateKey: Data) throws -> String {
        fatalError()
    }
    
    public func signMessage(message: SignMessage, privateKey: Data) throws -> String {
        fatalError()
    }
}
