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

    public func signPerpetual(input: SignerInput, privateKey: Data) throws -> [String] {
        guard case .perpetual(let asset, let type) = input.type else {
            throw AnyError("Invalid input type for perpetual signing")
        }
        NSLog("asset \(asset), type \(type)")

        let (agentAddress, agentKey) = try getAgentKey()
        let timestamp = Date.getTimestampInMs()

        // simple check for now, passed from hypercore service.
        if input.sequence > 0 {
            return try [
                signMarketMessage(type: type, agentKey: agentKey),
            ]
        } else {
            let agentName = "gemwallet_" + agentAddress.suffix(6)
            let agent = factory.makeApproveAgent(name: agentName, address: agentAddress, nonce: timestamp)
            let eip712Message = hyperCore.approveAgentTypedData(agent: agent)
            let signature = try signEIP712(messageJson: eip712Message, privateKey: privateKey)

            return try [
                actionMessage(signature: signature, eip712Message: eip712Message, timestamp: timestamp),
                signMarketMessage(type: type, agentKey: agentKey),
            ]
        }
    }

    public func signWithdraw(input: SignerInput, privateKey: Data) throws -> String {
        // FIXME: make sure input.amount is correct  ("2" means 2 USD)
        let timestamp = Date.getTimestampInMs()
        let request = factory.makeWithdraw(amount: input.value.description, address: input.senderAddress.lowercased(), nonce: timestamp)
        let eip712Message = hyperCore.withdrawalRequestTypedData(request: request)
        let signature = try signEIP712(messageJson: eip712Message, privateKey: privateKey)

        return try actionMessage(signature: signature, eip712Message: eip712Message, timestamp: timestamp)
    }

    private func signEIP712(messageJson: String, privateKey: Data) throws -> String {
        let hash = EthereumAbi.encodeTyped(messageJson: messageJson)
        guard let signature = PrivateKey(data: privateKey)!.sign(digest: hash, curve: .secp256k1) else {
            throw AnyError("Failed to sign")
        }
        return signature.hexString.append0x
    }

    private func signMarketMessage(type: PerpetualType, agentKey: Data) throws -> String {
        let timestamp = Date.getTimestampInMs()

        let signature: String
        let actionJson: String
        switch type {
        case .close(let asset, let price, let size):
            let order = factory.makeMarketClose(asset: asset, price: price, size: size, reduceOnly: true)
            let eip712Message = hyperCore.placeOrderTypedData(order: order, nonce: timestamp)
            signature = try signEIP712(messageJson: eip712Message, privateKey: agentKey)
            actionJson = factory.serializeOrder(order: order)

        case .open(let direction, let asset, let price, let size):
            let isBuy = switch direction {
            case .long: true
            case .short: false
            }
            let order = factory.makeMarketOpen(asset: asset, isBuy: isBuy, price: price, size: size, reduceOnly: true)
            let eip712Message = hyperCore.placeOrderTypedData(order: order, nonce: timestamp)
            signature = try signEIP712(messageJson: eip712Message, privateKey: agentKey)
            actionJson = factory.serializeOrder(order: order)
        }
        return factory.buildSignedRequest(signature: signature, action: actionJson, timestamp: timestamp)
    }

    private func actionMessage(signature: String, eip712Message: String, timestamp: UInt64) throws -> String {
        let eip712Json = try JSONSerialization.jsonObject(with: eip712Message.data(using: .utf8)!) as! [String: Any]
        let actionJson = try JSONSerialization.data(withJSONObject: eip712Json["message"]!).encodeString()
        return factory.buildSignedRequest(signature: signature, action: actionJson, timestamp: timestamp)
    }
}
