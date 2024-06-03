// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt

struct Payment: Equatable {
    let address: String
    let amount: String?
    let memo: String?
    var network: String?
}

struct PaymentURLDecoder {
    private let chainSchemes = Chain.allCases.map({ $0.rawValue })

    func decode(_ string: String) throws -> Payment {
        guard !string.isEmpty else {
            throw AnyError("Input string is empty")
        }

        let chunks = string.split(separator: ":")
        guard chunks.count >= 2 else {
            return try parseAddressAndNetwork(path: string)
        }

        let scheme = String(chunks[0])
        guard chainSchemes.contains(scheme) else {
            throw AnyError("Unsupported scheme: \(scheme)")
        }

        let path = String(chunks[1])
        let pathChunks = path.split(separator: "?")

        if pathChunks.count == 1 {
            return try parseAddressAndNetwork(path: String(pathChunks[0]))
        } else if pathChunks.count == 2 {
            return try parseBIP21(path: String(pathChunks[0]), query: String(pathChunks[1]))
        }

        throw AnyError("Invalid URL format")
    }
}

// MARK: - Private

extension PaymentURLDecoder {
    private func parseAddressAndNetwork(path: String) throws -> Payment {
        let addressAndNetwork = path.split(separator: "@")

        if addressAndNetwork.count == 2 {
            let address = String(addressAndNetwork[0])
            let networkHex = String(addressAndNetwork[1])
            let network = BigInt(hex: networkHex)?.description
            return Payment(address: address, amount: .none, memo: .none, network: network)
        } else if addressAndNetwork.count == 1 {
            return Payment(address: String(path), amount: .none, memo: .none, network: .none)
        }

        throw AnyError("Invalid address or network format")
    }

    private func parseBIP21(path: String, query: String) throws -> Payment {
        let addressAndNetwork = path.split(separator: "@")
        let address: String
        let network: String?

        if addressAndNetwork.count == 2 {
            address = String(addressAndNetwork[0])
            let networkHex = String(addressAndNetwork[1])
            network = BigInt(hex: networkHex)?.description
        } else {
            address = String(addressAndNetwork[0])
            network = .none
        }

        let params = decodeQueryString(query)
        let amount = params["amount"]
        let memo = params["memo"]

        return Payment(address: address, amount: amount, memo: memo, network: network)
    }

    private func decodeQueryString(_ queryString: String) -> [String: String] {
        return Dictionary(
            uniqueKeysWithValues: queryString
                .split(separator: "&")
                .compactMap { pair in
                    let components = pair.split(separator: "=")
                    guard components.count == 2 else { return nil }
                    let key = String(components[0]).removingPercentEncoding ?? String(components[0])
                    let value = String(components[1]).removingPercentEncoding ?? String(components[1])
                    return (key, value)
                }
        )
    }
}
