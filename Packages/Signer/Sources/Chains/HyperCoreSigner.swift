// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Foundation
import Gemstone
import GemstonePrimitives
import Keystore
import Primitives
import WalletCore
import WalletCorePrimitives

public class HyperCoreSigner: Signable {
    public func signTransfer(input: SignerInput, privateKey: Data) throws -> String {
        fatalError()
    }

    public func signPerpetual(input: SignerInput, privateKey: Data) throws -> String {
        guard case .perpetual(let asset, let type) = input.type else {
            throw AnyError("Invalid input type for perpetual signing")
        }
        NSLog("asset \(asset), type \(type)")

        let hyperCore = HyperCore()
        let modelFactory = HyperCoreModelFactory()
        let timestamp = UInt64(Date().timeIntervalSince1970 * 1000)

        switch type {
        case .approveAgent(let name, let address):
            let agent = modelFactory.makeApproveAgent(name: name, address: address, nonce: timestamp)
            let eip712Message = hyperCore.encodeApproveAgent(agent: agent)
            return try signEIP712(messageJson: eip712Message, privateKey: privateKey)
        case .close(let asset, let price, let size):
            let order = modelFactory.makeMarketClose(asset: asset, price: price, size: size, reduceOnly: true)
            let eip712Message = hyperCore.encodePlaceOrder(order: order, nonce: timestamp)
            return try signEIP712(messageJson: eip712Message, privateKey: privateKey)
        case .open(let direction, let asset, let price, let size):
            let isBuy = switch direction {
            case .long: true
            case .short: false
            }
            let order = modelFactory.makeMarketOpen(asset: asset, isBuy: isBuy, price: price, size: size, reduceOnly: true)
            let eip712Message = hyperCore.encodePlaceOrder(order: order, nonce: timestamp)
            return try signEIP712(messageJson: eip712Message, privateKey: privateKey)
        case .withdraw:
            // FIXME: make sure input.amount is correct  ("2" means 2 USD)
            let request = modelFactory.makeWithdraw(amount: input.value.description, address: input.senderAddress, nonce: timestamp)
            let eip712_json = hyperCore.encodeWithdrawalRequest(request: request)
            return try signEIP712(messageJson: eip712_json, privateKey: privateKey)
        }
    }

    private func signEIP712(messageJson: String, privateKey: Data) throws -> String {
        let hash = EthereumAbi.encodeTyped(messageJson: messageJson)
        guard let signature = PrivateKey(data: privateKey)!.sign(digest: hash, curve: .secp256k1) else {
            throw AnyError("Failed to sign")
        }
        return signature.hexString.append0x
    }
}
