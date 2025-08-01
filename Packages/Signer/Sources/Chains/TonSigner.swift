// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletCore
import Keystore
import Primitives
import BigInt

public struct TonSigner: Signable {
    public func signTransfer(input: SignerInput, privateKey: Data) throws -> String {
        let transfer = TheOpenNetworkTransfer.with {
            $0.dest = input.destinationAddress
            $0.amount = input.value.serialize()
            if let memo = input.memo {
                $0.comment = memo
            }
            $0.mode = UInt32(TheOpenNetworkSendMode.payFeesSeparately.rawValue | TheOpenNetworkSendMode.ignoreActionPhaseErrors.rawValue)
            $0.bounceable = false
        }

        return try sign(input: input, messages: [transfer], coinType: input.coinType, privateKey: privateKey)
    }

    public func signTokenTransfer(input: SignerInput, privateKey: Data) throws -> String {
        guard let jettonCreationFee = input.fee.options[.tokenAccountCreation] else {
            throw AnyError("Invalid token creation fee")
        }

        let transfer = TheOpenNetworkTransfer.with {
            $0.dest = input.token.senderTokenAddress // My Jetton Wallet address
            $0.amount = jettonCreationFee.serialize()
            if let memo = input.memo {
                $0.comment = memo
            }
            $0.mode = UInt32(TheOpenNetworkSendMode.payFeesSeparately.rawValue | TheOpenNetworkSendMode.ignoreActionPhaseErrors.rawValue)
            $0.bounceable = true
            $0.jettonTransfer = .with {
                $0.jettonAmount = input.value.serialize()
                $0.toOwner = input.destinationAddress
                $0.responseAddress = input.senderAddress
                $0.forwardAmount = BigInt(1).serialize()
            }
        }

        return try sign(input: input, messages: [transfer], coinType: input.coinType, privateKey: privateKey)
    }
    
    private func sign(input: SignerInput, messages: [TW_TheOpenNetwork_Proto_Transfer], coinType: CoinType, privateKey: Data) throws -> String {
        let signingInput = TheOpenNetworkSigningInput.with {
            $0.walletVersion = TheOpenNetworkWalletVersion.walletV4R2
            $0.sequenceNumber = UInt32(input.sequence)
            $0.expireAt = expireAt()
            $0.messages = messages
            $0.privateKey = privateKey
        }
        let output = (AnySigner.sign(input: signingInput, coin: coinType) as TheOpenNetworkSigningOutput)

        if !output.errorMessage.isEmpty {
            throw AnyError(output.errorMessage)
        }

        return output.encoded
    }
    
    public func signSwap(input: SignerInput, privateKey: Data) throws -> [String] {
        let data = try input.type.swap().data.data
        let transfer = try TheOpenNetworkTransfer.with {
            $0.dest = data.to
            $0.amount = try BigInt.from(string: data.value).serialize()
            if let memo = input.memo {
                $0.comment = memo
            }
            $0.mode = UInt32(TheOpenNetworkSendMode.payFeesSeparately.rawValue | TheOpenNetworkSendMode.ignoreActionPhaseErrors.rawValue)
            $0.bounceable = true
            $0.customPayload = data.data
        }
        return [
            try sign(input: input, messages: [transfer], coinType: input.coinType, privateKey: privateKey),
        ]
    }

    private func expireAt() -> UInt32 {
        UInt32(Date.now.timeIntervalSince1970 + TimeInterval(600))
    }
}
