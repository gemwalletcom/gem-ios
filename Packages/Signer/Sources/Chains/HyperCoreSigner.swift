// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Foundation
import Gemstone
import GemstonePrimitives
import Keystore
import Primitives
import WalletCore
import WalletCorePrimitives
import Keychain
import Blockchain

public class HyperCoreSigner: Signable {
    
    static let keychain = KeychainDefault()
    let hyperCore = HyperCore()
    let factory = HyperCoreModelFactory()
    
    public func signTransfer(input: SignerInput, privateKey: Data) throws -> String {
        fatalError()
    }
    
    func getAgentKey() throws -> (address: String, key: Data) {
        if let key = try Self.keychain.get(HyperCoreService.HLAgentKey), let address = try Self.keychain.get(HyperCoreService.HLAgentAddress) {
            return (address: address, try Data.from(hex: key))
        }
        let newKeyHex = try SecureRandom.generateKey()
        let newKey = try Data.from(hex: newKeyHex)
        let newAddress = CoinType.ethereum.deriveAddress(privateKey: PrivateKey(data: newKey)!)
        
        try Self.keychain.set(newKeyHex, key: HyperCoreService.HLAgentKey)
        try Self.keychain.set(newAddress, key: HyperCoreService.HLAgentAddress)
        
        return (address: newAddress, key: newKey)
    }

    public func signPerpetual(input: SignerInput, privateKey: Data) throws -> [String] {
        guard case .perpetual(let asset, let type) = input.type else {
            throw AnyError("Invalid input type for perpetual signing")
        }
        NSLog("asset \(asset), type \(type)")
        
        let (agentAddress, agentKey) = try getAgentKey()
        let timestamp = UInt64(Date().timeIntervalSince1970 * 1000)
        
        // simple check for now, passed from hypercore service.
        if input.sequence > 0 {
            return [
                try self.signMarketMessage(type: type, agentKey: agentKey),
            ]
        } else {
            let agentName = "gemwallet_" + agentAddress.suffix(6)
            let agent = factory.makeApproveAgent(name: agentName, address: agentAddress, nonce: timestamp)
            let eip712Message = hyperCore.encodeApproveAgent(agent: agent)
            let signature = try signEIP712(messageJson: eip712Message, privateKey: privateKey)
            
            return [
                try self.actionMessage(signature: signature, eip712Message: eip712Message, timestamp: timestamp),
                try self.signMarketMessage(type: type, agentKey: agentKey),
            ]
        }
    }

    private func signEIP712(messageJson: String, privateKey: Data) throws -> String {
        let hash = EthereumAbi.encodeTyped(messageJson: messageJson)
        guard let signature = PrivateKey(data: privateKey)!.sign(digest: hash, curve: .secp256k1) else {
            throw AnyError("Failed to sign")
        }
        return signature.hexString.append0x
    }
    
    private func signMarketMessage(type: PerpetualType, agentKey: Data) throws -> String {
        let timestamp = UInt64(Date().timeIntervalSince1970 * 1000)
        
        let signature: String
        let eip712Message: String
        switch type {
        case .close(let asset, let price, let size):
            let order = factory.makeMarketClose(asset: asset, price: price, size: size, reduceOnly: true)
            eip712Message = hyperCore.encodePlaceOrder(order: order, nonce: timestamp)
            signature = try signEIP712(messageJson: eip712Message, privateKey: agentKey)
        case .open(let direction, let asset, let price, let size):
            let isBuy = switch direction {
            case .long: true
            case .short: false
            }
            let order = factory.makeMarketOpen(asset: asset, isBuy: isBuy, price: price, size: size, reduceOnly: true)
            eip712Message = hyperCore.encodePlaceOrder(order: order, nonce: timestamp)
            signature = try signEIP712(messageJson: eip712Message, privateKey: agentKey)
//        case .withdraw:
//            // FIXME: make sure input.amount is correct  ("2" means 2 USD)
//            let request = factory.makeWithdraw(amount: input.value.description, address: input.senderAddress.lowercased(), nonce: timestamp)
//            let eip712_json = hyperCore.encodeWithdrawalRequest(request: request)
//            signature = try signEIP712(messageJson: eip712_json, privateKey: privateKey)
        }
        return try actionMessage(signature: signature, eip712Message: eip712Message, timestamp: timestamp)
    }
    
    private func actionMessage(signature: String, eip712Message: String, timestamp: UInt64) throws -> String {
        let eip712Json = try JSONSerialization.jsonObject(with: eip712Message.data(using: .utf8)!) as! [String: Any]
        let (r, s, v) = try SignatureParser.parseSignature(signature)
        let dictionary: [String: Any] = [
            "action": eip712Json["message"]!,
            "signature": [
                "r": r,
                "s": s,
                "v": v,
            ],
            "nonce": timestamp,
            "isFrontend": true,
        ]
        return try JSONSerialization.data(withJSONObject: dictionary, options: [.sortedKeys]).encodeString()
    }
}
