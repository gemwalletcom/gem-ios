// Copyright (c). Gem Wallet. All rights reserved.

import CryptoKit
import Foundation
import protocol Gemstone.AlienProvider
import struct Gemstone.AlienResponse
import struct Gemstone.AlienTarget
import enum Gemstone.AlienError
import typealias Gemstone.Chain
import Primitives

public actor NativeProvider {
    private let session: URLSession
    private let nodeProvider: any NodeURLFetchable
    private let cache: any ProviderCache

    public init(
        session: URLSession = .shared,
        nodeProvider: any NodeURLFetchable
    ) {
        self.session = session
        self.nodeProvider = nodeProvider
        self.cache = MemoryCache()
    }

    public init(session: URLSession = .shared, url: URL) {
        self.session = session
        self.nodeProvider = StaticNode(url: url)
        self.cache = MemoryCache()
    }
}

public struct StaticNode: NodeURLFetchable {
    let url: URL

    public init(url: URL) {
        self.url = url
    }

    public func node(for chain: Primitives.Chain) -> URL { url
    }
}

extension NativeProvider: AlienProvider {
    public func request(target: AlienTarget) async throws -> AlienResponse {
        if let data = await cache.get(key: target.cacheKey) {
            return AlienResponse(status: 200, data: data)
        }

        let (data, response) = try await session.data(for: target.asRequest())
        let statusCode = (response as? HTTPURLResponse)?.statusCode

        if let ttl = target.headers?["x-cache-ttl"], let duration = Int(ttl) {
            await cache.set(key: target.cacheKey, value: data, ttl: Duration.seconds(duration))
        }

        return AlienResponse(status: statusCode.map(UInt16.init), data: data)
    }

    public nonisolated func getEndpoint(chain: Chain) throws -> String {
        nodeProvider.node(for: try Primitives.Chain(id: chain)).absoluteString
    }
}

extension AlienTarget {
    var cacheKey: String {
        let bodyHex = body?.map { String(format: "%02x", $0) }.joined() ?? ""
        let string = [url, method.hashValue.asString, headers?.description, bodyHex].compactMap { $0 }.joined()
        return SHA256.hash(data: Data(string.utf8)).description
    }
}
