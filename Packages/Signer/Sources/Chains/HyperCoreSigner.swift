// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Blockchain
import Formatters
import Foundation
import Gemstone
import GemstonePrimitives
import Primitives

public class HyperCoreSigner: Signable {
    private let hyperCore: HyperCore
    private let factory = HyperCoreModelFactory()
    private let agentNamePrefix = "gemwallet_"
    private let referralCode = "GEMWALLET"
    private let builderAddress = "0x0d9dab1a248f63b0a48965ba8435e4de7497a3dc"
    private let nativeSpotToken = "HYPE:0x0d01dc56dcaaca66ad901c959b4011ec"

    public init() {
        hyperCore = HyperCore(signer: NativeSigner())
    }

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
        let (symbol, tokenId) = try input.asset.id.twoSubTokenIds()
        return try signSpotSend(
            amount: amount,
            destination: input.destinationAddress,
            token: "\(symbol):\(tokenId)",
            privateKey: privateKey
        )
    }

    public func signSwap(input: SignerInput, privateKey: Data) throws -> [String] {
        guard case let .swap(_, _, swapData) = input.type else {
            throw AnyError("Invalid Swap Data")
        }

        return try [hyperCore.signTypedAction(typedDataJson: swapData.data.data, privateKey: privateKey)]
    }

    public func signStake(input: SignerInput, privateKey: Data) throws -> [String] {
        guard case let .stake(_, stakeType) = input.type else {
            throw AnyError("Invalid input type for stake signing")
        }

        let nonceIncrementer = NumberIncrementer(Date.getTimestampInMs())
        let denominator = BigInt(10).power(10)
        switch stakeType {
        case let .stake(validator):
            let wei = input.value / denominator
            let depositAction = try signStakingTransfer(wei: wei.asUInt, nonce: nonceIncrementer.next(), privateKey: privateKey)
            let request = factory.makeDelegate(validator: validator.id, wei: wei.asUInt, nonce: nonceIncrementer.next())
            let delegateAction = try hyperCore.signTokenDelegate(delegate: request, privateKey: privateKey)
            return [
                depositAction,
                delegateAction
            ]
        case let .unstake(delegation):
            let wei = delegation.base.balanceValue / denominator
            let request = factory.makeUndelegate(validator: delegation.validator.id, wei: wei.asUInt, nonce: nonceIncrementer.current())
            let undelegateAction = try hyperCore.signTokenDelegate(delegate: request, privateKey: privateKey)
            let withdrawAction = try signStakingWithdraw(wei: wei.asUInt, nonce: nonceIncrementer.next(), privateKey: privateKey)
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
        guard case let .perpetual(_, type) = input.type, case let .hyperliquid(order) = input.metadata else {
            throw AnyError("Invalid input type for perpetual signing")
        }

        guard let order = order else {
            throw AnyError("Hyperliquid order metadata is required for perpetual signing")
        }

        let agentKey = try Data.from(hex: order.agentPrivateKey)
        let builder = try? getBuilder(builder: builderAddress, fee: Int(order.builderFeeBps))
        let timestampIncrementer = NumberIncrementer(Int(Date.getTimestampInMs()))
        var transactions: [String] = []

        if order.approveReferralRequired {
            try transactions.append(
                signSetReferer(
                    agentKey: privateKey,
                    code: referralCode,
                    timestamp: timestampIncrementer.next().asUInt64
                )
            )
        }
        if order.approveAgentRequired {
            try transactions.append(
                signApproveAgent(
                    agentAddress: order.agentAddress,
                    privateKey: privateKey,
                    timestamp: timestampIncrementer.next().asUInt64
                )
            )
        }
        if order.approveBuilderRequired {
            try transactions.append(
                signApproveBuilderAddress(
                    agentKey: privateKey,
                    builderAddress: builderAddress,
                    rateBps: order.builderFeeBps,
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
        return try hyperCore.signApproveAgent(agent: agent, privateKey: privateKey)
    }

    public func signWithdrawal(input: SignerInput, privateKey: Data) throws -> String {
        let timestamp = UInt64(Date.getTimestampInMs())
        let amount = BigNumberFormatter.standard.string(from: input.value, decimals: Int(input.asset.decimals))
        let request = factory.makeWithdraw(amount: amount, address: input.senderAddress.lowercased(), nonce: timestamp)
        return try hyperCore.signWithdrawalRequest(request: request, privateKey: privateKey)
    }

    public func feeRate(_ tenthsBps: UInt32) -> String {
        String(format: "%g%%", Double(tenthsBps) * 0.001)
    }

    // "0.05%" = 50bps. 1 means 0.001%
    public func signApproveBuilderAddress(agentKey: Data, builderAddress: String, rateBps: UInt32, timestamp: UInt64) throws -> String {
        let maxFeeRate = feeRate(rateBps)
        let request = factory.makeApproveBuilder(maxFeeRate: maxFeeRate, builder: builderAddress, nonce: timestamp)
        return try hyperCore.signApproveBuilderFee(fee: request, privateKey: agentKey)
    }

    private func signSetReferer(agentKey: Data, code: String, timestamp: UInt64) throws -> String {
        let referer = factory.makeSetReferrer(referrer: code)
        return try hyperCore.signSetReferrer(referrer: referer, nonce: timestamp, privateKey: agentKey)
    }

    private func signSpotSend(amount: String, destination: String, token: String, privateKey: Data) throws -> String {
        let timestamp = UInt64(Date.getTimestampInMs())
        let spotSend = factory.sendSpotTokenToAddress(
            amount: amount,
            destination: destination.lowercased(),
            time: timestamp,
            token: token
        )
        return try hyperCore.signSpotSend(spotSend: spotSend, privateKey: privateKey)
    }

    private func signStakingTransfer(wei: UInt64, nonce: UInt64, privateKey: Data) throws -> String {
        let depositRequest = factory.makeTransferToStaking(wei: wei, nonce: nonce)
        return try hyperCore.signCDeposit(deposit: depositRequest, privateKey: privateKey)
    }

    private func signStakingWithdraw(wei: UInt64, nonce: UInt64, privateKey: Data) throws -> String {
        let request = factory.makeWithdrawFromStaking(wei: wei, nonce: nonce)
        return try hyperCore.signCWithdraw(withdraw: request, privateKey: privateKey)
    }

    private func signMarketMessage(type: Primitives.PerpetualType, agentKey: Data, builder: HyperBuilder?, timestamp: UInt64) throws -> String {
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
        case let .autoclose(data):
            factory.makePositionTpSl(
                asset: UInt32(data.assetIndex),
                isBuy: data.direction == .long,
                size: data.size,
                tpTrigger: data.price,
                slTrigger: data.direction == .long ? "0.001" : "999999",
                builder: builder
            )
        }
        return try hyperCore.signPlaceOrder(order: order, nonce: timestamp, privateKey: agentKey)
    }
}
