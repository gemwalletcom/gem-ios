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
    static let keychain = KeychainDefault()
    let hyperCore = HyperCore()
    let factory = HyperCoreModelFactory()
    private let agentNamePrefix = "gemwallet_"
    private let referralCode = "GEMWALLET"
    private let builderAddress = "0x0D9DAB1A248f63B0a48965bA8435e4de7497a3dC"

    public func signTransfer(input: SignerInput, privateKey: Data) throws -> String {
        fatalError()
    }

    func getAgentKey() throws -> (address: String, key: Data) {
        if let key = try Self.keychain.get(HyperCoreService.HLAgentKey),
           let address = try Self.keychain.get(HyperCoreService.HLAgentAddress)
        {
            return try (address: address, Data.from(hex: key))
        }
        let newKey = try SecureRandom.generateKey()
        let newAddress = CoinType.ethereum.deriveAddress(privateKey: PrivateKey(data: newKey)!)

        try Self.keychain.set(newKey.hexString, key: HyperCoreService.HLAgentKey)
        try Self.keychain.set(newAddress, key: HyperCoreService.HLAgentAddress)

        return (address: newAddress, key: newKey)
    }

    private func getBuilder() throws -> HyperBuilder {
        return HyperBuilder(builderAddress: builderAddress, fee: 50)
    }

    public func signPerpetual(input: SignerInput, privateKey: Data) throws -> [String] {
        guard case let .perpetual(_, type) = input.type else {
            throw AnyError("Invalid input type for perpetual signing")
        }

        let (agentAddress, agentKey) = try getAgentKey()
        let builder = try? getBuilder()
        let timestamp = Date.getTimestampInMs()

        // simple check for now, passed from hypercore service.
        if input.sequence > 0 {
            return try [
                signMarketMessage(type: type, agentKey: agentKey, timestamp: timestamp, builder: builder),
            ]
        } else {
            return try [
                signApproveAgent(agentAddress: agentAddress, privateKey: privateKey, timestamp: timestamp),
                signApproveBuilderAddress(agentKey: agentKey, timestamp: timestamp),
                signSetReferer(agentKey: agentKey, timestamp: timestamp),
                signMarketMessage(type: type, agentKey: agentKey, timestamp: timestamp, builder: builder),
            ]
        }
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

    public func signWithdraw(input: SignerInput, privateKey: Data) throws -> String {
        // FIXME: make sure input.amount is correct  ("2" means 2 USD)
        let timestamp = Date.getTimestampInMs()
        let request = factory.makeWithdraw(amount: input.value.description, address: input.senderAddress.lowercased(), nonce: timestamp)
        let eip712Message = hyperCore.withdrawalRequestTypedData(request: request)
        let signature = try signEIP712(messageJson: eip712Message, privateKey: privateKey)

        return try actionMessage(signature: signature, eip712Message: eip712Message, timestamp: timestamp)
    }
    
    public func signApproveBuilderAddress(agentKey: Data, timestamp: UInt64) throws -> String {
        let timestamp = Date.getTimestampInMs()
        let request = factory.makeApproveBuilder(maxFeeRate: "10", builder: builderAddress, nonce: timestamp)
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

     private func signSetReferer(agentKey: Data, timestamp: UInt64) throws -> String {
         let referer = factory.makeSetReferrer(referrer: referralCode)
         let eip712Message = hyperCore.setReferrerTypedData(referrer: referer, nonce: timestamp)
         let signature = try signEIP712(messageJson: eip712Message, privateKey: agentKey)
         return factory.buildSignedRequest(
             signature: signature,
             action: factory.serializeSetReferrer(setReferrer: referer),
             timestamp: timestamp
         )
     }

    private func signMarketMessage(type: PerpetualType, agentKey: Data, timestamp: UInt64, builder: HyperBuilder?) throws -> String {
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
