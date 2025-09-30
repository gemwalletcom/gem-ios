// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Blockchain
import Formatters
import Foundation
import Gemstone
import GemstonePrimitives
import Primitives
import WalletCore
import WalletCorePrimitives

public class HyperCoreSigner: Signable {
    private let hyperCore = HyperCore()
    private let factory = HyperCoreModelFactory()
    private let agentNamePrefix = "gemwallet_"
    private let referralCode = "GEMWALLET"
    private let builderAddress = "0x0d9dab1a248f63b0a48965ba8435e4de7497a3dc"
    private let nativeSpotToken = "HYPE:0x0d01dc56dcaaca66ad901c959b4011ec"

    public init() {}

    public func signTransfer(input: SignerInput, privateKey: Data) throws -> String {
        let amount = BigNumberFormatter.standard.string(from: input.value, decimals: Int(input.asset.decimals))
        return try signSpotSend(
            amount: amount,
            destination: input.destinationAddress,
            token: nativeSpotToken,
            privateKey: privateKey
        )
    }

    public func signTokenTransfer(input: SignerInput, privateKey: Data) throws -> String {
        let amount = BigNumberFormatter.standard.string(from: input.value, decimals: Int(input.asset.decimals))
        let parts = try input.asset.getTokenId().split(separator: "::").map { String($0) }
        let token = try "\(parts.getElement(safe: 0)):\(parts.getElement(safe: 1))"
        return try signSpotSend(
            amount: amount,
            destination: input.destinationAddress,
            token: token,
            privateKey: privateKey
        )
    }

    public func signSwap(input: SignerInput, privateKey: Data) throws -> [String] {
        guard case let .swap(_, _, swapData) = input.type else {
            throw AnyError("Invalid Swap Data")
        }

        let signature = try signEIP712(messageJson: swapData.data.data, privateKey: privateKey)
        let eip712Json = try JSONSerialization.jsonObject(with: swapData.data.data.data(using: .utf8)!) as! [String: Any]
        let actionJson = eip712Json["message"] as! [String: Any]
        return try [
            factory.buildSignedRequest(
                signature: signature,
                action: JSONSerialization.data(withJSONObject: actionJson).encodeString(),
                timestamp: actionJson["time"] as! UInt64
            )
        ]
    }

    public func signStake(input: SignerInput, privateKey: Data) throws -> [String] {
        guard case let .stake(_, stakeType) = input.type else {
            throw AnyError("Invalid input type for stake signing")
        }

        let timestamp = UInt64(Date.getTimestampInMs())
        let denominator = BigInt(10).power(10)
        switch stakeType {
        case let .stake(validator):
            let wei = input.value / denominator
            let depositAction = try signStakingTransfer(wei: wei.asUInt, nonce: timestamp, privateKey: privateKey)
            let delegateAction = try signTokenDelegate(
                validator: validator.id,
                wei: wei.asUInt,
                nonce: timestamp + 1,
                isUndelegate: false,
                privateKey: privateKey
            )
            return [
                depositAction,
                delegateAction
            ]
        case let .unstake(delegation):
            let wei = delegation.base.balanceValue / denominator
            let undelegateAction = try signTokenDelegate(
                validator: delegation.validator.id,
                wei: wei.asUInt,
                nonce: timestamp,
                isUndelegate: true,
                privateKey: privateKey
            )
            let withdrawAction = try signStakingWithdraw(wei: wei.asUInt, nonce: timestamp + 1, privateKey: privateKey)
            return [
                undelegateAction,
                withdrawAction
            ]
        case .freeze, .redelegate, .rewards, .withdraw:
            throw AnyError("Not supported stake type")
        }
    }

    private func getBuilder(builder: String, fee: Int) throws -> HyperBuilder {
        return HyperBuilder(builderAddress: builder, fee: fee.asUInt32)
    }

    public func signPerpetual(input: SignerInput, privateKey: Data) throws -> [String] {
        guard case let .perpetual(_, type) = input.type, case let .hyperliquid(approveAgentRequired, approveReferralRequired, approveBuilderRequired, builderFeeBps, agentAddress, agentPrivateKey) = input.metadata else {
            throw AnyError("Invalid input type for perpetual signing")
        }

        let agentKey = try Data.from(hex: agentPrivateKey)
        let builder = try? getBuilder(builder: builderAddress, fee: Int(builderFeeBps))
        let timestampIncrementer = NumberIncrementer(Int(Date.getTimestampInMs()))
        var transactions: [String] = []

        if approveReferralRequired {
            try transactions.append(
                signSetReferer(
                    agentKey: privateKey,
                    code: referralCode,
                    timestamp: timestampIncrementer.next().asUInt64
                )
            )
        }
        if approveAgentRequired {
            try transactions.append(
                signApproveAgent(
                    agentAddress: agentAddress,
                    privateKey: privateKey,
                    timestamp: timestampIncrementer.next().asUInt64
                )
            )
        }
        if approveBuilderRequired {
            try transactions.append(
                signApproveBuilderAddress(
                    agentKey: privateKey,
                    builderAddress: builderAddress,
                    rateBps: builderFeeBps,
                    timestamp: timestampIncrementer.next().asUInt64
                )
            )
        }
        try transactions.append(
            signMarketMessage(
                type: type,
                agentKey: agentKey,
                builder: builder,
                timestamp: timestampIncrementer.next().asUInt64
            )
        )

        return transactions
    }

    public func signApproveAgent(agentAddress: String, privateKey: Data, timestamp: UInt64) throws -> String {
        let agentName = agentNamePrefix + agentAddress.suffix(6)
        let agent = factory.makeApproveAgent(name: agentName, address: agentAddress, nonce: timestamp)
        let eip712Message = hyperCore.approveAgentTypedData(agent: agent)
        return try actionMessage(
            signature: signEIP712(messageJson: eip712Message, privateKey: privateKey),
            eip712Message: eip712Message,
            timestamp: timestamp
        )
    }

    public func signWithdrawal(input: SignerInput, privateKey: Data) throws -> String {
        let timestamp = UInt64(Date.getTimestampInMs())
        let amount = BigNumberFormatter.standard.string(from: input.value, decimals: Int(input.asset.decimals))
        let request = factory.makeWithdraw(amount: amount, address: input.senderAddress.lowercased(), nonce: timestamp)
        let eip712Message = hyperCore.withdrawalRequestTypedData(request: request)
        let signature = try signEIP712(messageJson: eip712Message, privateKey: privateKey)

        return try actionMessage(signature: signature, eip712Message: eip712Message, timestamp: timestamp)
    }

    public func feeRate(_ tenthsBps: UInt32) -> String {
        String(format: "%g%%", Double(tenthsBps) * 0.001)
    }

    // "0.05%" = 50bps. 1 means 0.001%
    public func signApproveBuilderAddress(agentKey: Data, builderAddress: String, rateBps: UInt32, timestamp: UInt64) throws -> String {
        let maxFeeRate = feeRate(rateBps)
        let request = factory.makeApproveBuilder(maxFeeRate: maxFeeRate, builder: builderAddress, nonce: timestamp)
        let eip712Message = hyperCore.approveBuilderFeeTypedData(fee: request)
        let signature = try signEIP712(messageJson: eip712Message, privateKey: agentKey)
        return try actionMessage(signature: signature, eip712Message: eip712Message, timestamp: timestamp)
    }

    private func signEIP712(messageJson: String, privateKey: Data) throws -> String {
        let hash = EthereumAbi.encodeTyped(messageJson: messageJson)
        guard let signature = PrivateKey(data: privateKey)!.sign(digest: hash, curve: .secp256k1) else {
            throw AnyError("Failed to sign")
        }
        return signature.hexString.append0x
    }

    private func signSetReferer(agentKey: Data, code: String, timestamp: UInt64) throws -> String {
        let referer = factory.makeSetReferrer(referrer: code)
        let eip712Message = hyperCore.setReferrerTypedData(referrer: referer, nonce: timestamp)
        let signature = try signEIP712(messageJson: eip712Message, privateKey: agentKey)
        return factory.buildSignedRequest(
            signature: signature,
            action: factory.serializeSetReferrer(setReferrer: referer),
            timestamp: timestamp
        )
    }

    private func signSpotSend(amount: String, destination: String, token: String, privateKey: Data) throws -> String {
        let timestamp = UInt64(Date.getTimestampInMs())
        let spotSend = factory.sendSpotTokenToAddress(
            amount: amount,
            destination: destination.lowercased(),
            time: timestamp,
            token: token
        )
        let eip712Message = hyperCore.sendSpotTokenToAddressTypedData(spotSend: spotSend)
        let signature = try signEIP712(messageJson: eip712Message, privateKey: privateKey)
        return try actionMessage(signature: signature, eip712Message: eip712Message, timestamp: timestamp)
    }

    private func signStakingTransfer(wei: UInt64, nonce: UInt64, privateKey: Data) throws -> String {
        let depositRequest = factory.makeTransferToStaking(wei: wei, nonce: nonce)
        let depoistMessage = hyperCore.cDepositTypedData(cDeposit: depositRequest)
        let depoistSignature = try signEIP712(messageJson: depoistMessage, privateKey: privateKey)
        return try actionMessage(signature: depoistSignature, eip712Message: depoistMessage, timestamp: nonce)
    }

    private func signStakingWithdraw(wei: UInt64, nonce: UInt64, privateKey: Data) throws -> String {
        let request = factory.makeWithdrawFromStaking(wei: wei, nonce: nonce)
        let message = hyperCore.cWithdrawTypedData(cWithdraw: request)
        let signature = try signEIP712(messageJson: message, privateKey: privateKey)
        return try actionMessage(signature: signature, eip712Message: message, timestamp: nonce)
    }

    private func signTokenDelegate(validator: String, wei: UInt64, nonce: UInt64, isUndelegate: Bool, privateKey: Data) throws -> String {
        let delegateRequest = switch isUndelegate {
        case true:
            factory.makeUndelegate(validator: validator, wei: wei, nonce: nonce)
        case false:
            factory.makeDelegate(validator: validator, wei: wei, nonce: nonce)
        }
        let delegateMessage = hyperCore.tokenDelegateTypedData(tokenDelegate: delegateRequest)
        let delegateSignature = try signEIP712(messageJson: delegateMessage, privateKey: privateKey)
        return try actionMessage(signature: delegateSignature, eip712Message: delegateMessage, timestamp: nonce)
    }

    private func signMarketMessage(type: PerpetualType, agentKey: Data, builder: HyperBuilder?, timestamp: UInt64) throws -> String {
        let order = switch type {
        case let .close(data):
            factory.makeMarketOrder(
                asset: UInt32(data.assetIndex),
                isBuy: data.direction == .short,
                price: data.price,
                size: data.size,
                reduceOnly: true,
                builder: builder
            )
        case let .open(data):
            factory.makeMarketOrder(
                asset: UInt32(data.assetIndex),
                isBuy: data.direction == .long,
                price: data.price,
                size: data.size,
                reduceOnly: false,
                builder: builder
            )
        }
        let eip712 = hyperCore.placeOrderTypedData(order: order, nonce: timestamp)
        return try factory.buildSignedRequest(
            signature: signEIP712(messageJson: eip712, privateKey: agentKey),
            action: factory.serializeOrder(order: order),
            timestamp: timestamp
        )
    }

    private func actionMessage(signature: String, eip712Message: String, timestamp: UInt64) throws -> String {
        let eip712Json = try JSONSerialization.jsonObject(with: eip712Message.data(using: .utf8)!) as! [String: Any]
        let actionJson = try JSONSerialization.data(withJSONObject: eip712Json["message"]!).encodeString()
        return factory.buildSignedRequest(signature: signature, action: actionJson, timestamp: timestamp)
    }
}
