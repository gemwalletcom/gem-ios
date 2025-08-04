// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Blockchain
import Foundation
import Gemstone
import GemstonePrimitives
import Keychain
import Keystore
import Primitives
import WalletCore
import WalletCorePrimitives

public class HyperCoreSigner: Signable {
    let keychain: Keychain
    let hyperCore = HyperCore()
    let factory = HyperCoreModelFactory()
    private let agentNamePrefix = "gemwallet_"
    
    public init(keychain: Keychain = KeychainDefault()) {
        self.keychain = keychain
    }

    public func signTransfer(input: SignerInput, privateKey: Data) throws -> String {
        fatalError()
    }

    func getAgentKey(for walletAddress: String) throws -> (address: String, key: Data) {
        let agentPrivateKeyName = "\(HyperCoreService.agentPrivateKey)_\(walletAddress)"
        let agentAddressKeyName = "\(HyperCoreService.agentAddressKey)_\(walletAddress)"
        
        if let key = try keychain.get(agentPrivateKeyName), let address = try keychain.get(agentAddressKeyName) {
            return try (address: address, Data.from(hex: key))
        }
        let newKey = try SecureRandom.generateKey()
        let newAddress = CoinType.ethereum.deriveAddress(privateKey: PrivateKey(data: newKey)!)

        try keychain.set(newKey.hexString, key: agentPrivateKeyName)
        try keychain.set(newAddress, key: agentAddressKeyName)

        return (address: newAddress, key: newKey)
    }
    
    private func getBuilder(builder: String, fee: Int) throws -> HyperBuilder {
        return HyperBuilder(builderAddress: builder, fee: fee.asUInt32)
    }

    public func signPerpetual(input: SignerInput, privateKey: Data) throws -> [String] {
        guard case let .perpetual(_, type) = input.type, case let .hyperliquid(data) = input.data else {
            throw AnyError("Invalid input type for perpetual signing")
        }

        let (agentAddress, agentKey) = try getAgentKey(for: input.senderAddress)
        let builder = try? getBuilder(builder: HyperCoreService.builderAddress, fee: HyperCoreService.builderFeeBps)
        // timestamp for each transaction should be increase to avoid duplicate nonce
        let timestamp = Date.getTimestampInMs()
        var transactions: [String] = []
        
        if data.approveReferralRequired {
            transactions.append(
                try signSetReferer(
                    agentKey: privateKey,
                    code: HyperCoreService.referralCode,
                    timestamp: timestamp
                )
            )
        }
        if data.approveAgentRequired {
            transactions.append(
                try signApproveAgent(agentAddress: agentAddress, privateKey: privateKey, timestamp: timestamp + 1)
            )
        }
        if data.approveBuilderRequired {
            transactions.append(
                try signApproveBuilderAddress(
                    agentKey: privateKey,
                    builderAddress: HyperCoreService.builderAddress,
                    rateBps: HyperCoreService.builderFeeBps,
                    timestamp: timestamp + 2
                )
            )
        }
        transactions.append(
            try signMarketMessage(type: type, agentKey: agentKey, builder: builder, timestamp: timestamp + 3)
        )
        
        return transactions
    }
    
    public func signApproveAgent(agentAddress: String, privateKey: Data, timestamp: UInt64) throws -> String {
        let agentName = agentNamePrefix + agentAddress.suffix(6)
        let agent = factory.makeApproveAgent(name: agentName, address: agentAddress, nonce: timestamp)
        let eip712Message = hyperCore.approveAgentTypedData(agent: agent)
        return try actionMessage(
            signature: try signEIP712(messageJson: eip712Message, privateKey: privateKey),
            eip712Message: eip712Message,
            timestamp: timestamp
        )
    }

    public func signWithdraw(input: SignerInput, privateKey: Data, timestamp: UInt64) throws -> String {
        // FIXME: make sure input.amount is correct  ("2" means 2 USD)
        let request = factory.makeWithdraw(amount: input.value.description, address: input.senderAddress.lowercased(), nonce: timestamp)
        let eip712Message = hyperCore.withdrawalRequestTypedData(request: request)
        let signature = try signEIP712(messageJson: eip712Message, privateKey: privateKey)

        return try actionMessage(signature: signature, eip712Message: eip712Message, timestamp: timestamp)
    }
    
    // "0.05%" = 50bps. 1 means 0.001%
    public func signApproveBuilderAddress(agentKey: Data, builderAddress: String, rateBps: Int, timestamp: UInt64) throws -> String {
        let maxFeeRate = HyperCoreService.feeRate(rateBps)
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

    private func signMarketMessage(type: PerpetualType, agentKey: Data, builder: HyperBuilder?, timestamp: UInt64) throws -> String {
        let order = switch type {
        case .close(let data):
            factory.makeMarketOrder(
                asset: data.assetIndex.asUInt32,
                isBuy: data.direction == .short,
                price: data.price,
                size: data.size,
                reduceOnly: true,
                builder: builder
            )
        case .open(let data):
            factory.makeMarketOrder(
                asset: data.assetIndex.asUInt32,
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
