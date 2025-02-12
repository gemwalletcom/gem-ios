// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient
import WalletCore
import BigInt

public struct ERC20Service: Sendable {
    
    let provider: Provider<EthereumTarget>
    
    public init(provider: Provider<EthereumTarget>) {
        self.provider = provider
    }
    
    public func decode(assetId: AssetId, address: String) async throws -> Asset {
        let calls = [
            getERC20NameCall(contract: address),
            getERC20SymbolCall(contract: address),
            getERC20DecimalsCall(contract: address)
        ]
        let results = try await provider.requestBatch(calls).map(as: [JSONRPCResponse<String>].self)
        let (name, symbol, decimals) = try decodeERC20Data(results: results)

        return Asset(
            id: assetId,
            name: name,
            symbol: symbol,
            decimals: decimals.asInt.asInt32,
            type: try assetId.getAssetType()
        )
    }
    
    private func getERC20DecimalsCall(contract: String) -> EthereumTarget {
        let data = EthereumAbi.encode(fn: EthereumAbiFunction(name: "decimals"))
        let params = [
            "to": contract,
            "data": data.hexString.append0x,
        ]
        return .call(params)
    }

    private func getERC20Decimals(contract: String) async throws -> BigInt {
        let call = getERC20DecimalsCall(contract: contract)
        return try await provider
            .request(call)
            .map(as: JSONRPCResponse<BigIntable>.self).result.value
    }

    private func getERC20NameCall(contract: String) -> EthereumTarget {
        let data = EthereumAbi.encode(fn: EthereumAbiFunction(name: "name"))
        let params = [
            "to": contract,
            "data": data.hexString.append0x,
        ]
        return .call(params)
    }

    private func getERC20Name(contract: String) async throws -> String {
        let call = getERC20NameCall(contract: contract)
        let response = try await provider
            .request(call)
            .map(as: JSONRPCResponse<String>.self).result
        return try Self.decodeABI(hexString: response)
    }

    private func getERC20SymbolCall(contract: String) -> EthereumTarget {
        let data = EthereumAbi.encode(fn: EthereumAbiFunction(name: "symbol"))
        let params = [
            "to": contract,
            "data": data.hexString.append0x,
        ]
        return .call(params)
    }

    private func getERC20Symbol(contract: String) async throws -> String {
        let call = getERC20SymbolCall(contract: contract)
        let response = try await provider
            .request(call)
            .map(as: JSONRPCResponse<String>.self).result
        return try Self.decodeABI(hexString: response)
    }
    
    private func decodeERC20Data(results: [JSONRPCResponse<String>]) throws -> (name: String, symbol: String, decimals: BigInt) {
        let name = try Self.decodeABI(hexString: try results.getElement(safe: 0).result)
        let symbol = try Self.decodeABI(hexString: try results.getElement(safe: 1).result)
        let data = try Data.from(hex: try results.getElement(safe: 2).result)
        let decimals = EthereumAbiValue.decodeUInt256(input: data)
        return (name, symbol, BigInt(stringLiteral: decimals))
    }
}

extension ERC20Service {
    // MARK: - Internal
    public static func decodeABI(hexString: String) throws -> String {
        // WalletCore decodeValue doesn't work as expected, need to drop first offset byte
        guard
            let data = Data(fromHex: hexString),
            data.count > 32
        else {
            throw AnyError("Invalid ABI hex string")
        }
        return EthereumAbiValue.decodeValue(input: data.dropFirst(32), type: "string")
    }
}
