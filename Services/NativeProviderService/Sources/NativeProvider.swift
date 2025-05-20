// Copyright (c). Gem Wallet. All rights reserved.

import ChainService
import CryptoKit
import Foundation
import Gemstone
import Primitives

public actor NativeProvider {
    let session: URLSession
    let nodeProvider: any NodeURLFetchable
    private let cache: any ProviderCache

    public init(
        session: URLSession = .shared,
        nodeProvider: any NodeURLFetchable
    ) {
        self.session = session
        self.nodeProvider = nodeProvider
        self.cache = MemoryCache()
    }
}

extension NativeProvider: AlienProvider {
    public func request(target: Gemstone.AlienTarget) async throws -> Data {
        let results = try await self.batchRequest(targets: [target])
        guard
            results.count == 1
        else {
            throw AlienError.ResponseError(msg: "invalid response: \(target)")
        }
        return results[0]
    }

    public nonisolated func getEndpoint(chain: Gemstone.Chain) throws -> String {
        self.nodeProvider.node(for: Primitives.Chain(rawValue: chain)!).absoluteString
    }

    public func batchRequest(targets: [AlienTarget]) async throws -> [Data] {
        return try await withThrowingTaskGroup(of: Data.self) { group in
            var results = [Data]()

            for target in targets {
                group.addTask {
                    print("==> handle request:\n\(target)")

                    if let data = await self.cache.get(key: target.cacheKey) {
                        return data
                    }

                    let (data, response) = try await self.session.data(for: target.asRequest())
                    let statusCode = (response as? HTTPURLResponse)?.statusCode
                    if statusCode != 200 && data.isEmpty {
                        throw AlienError.ResponseError(msg: "Invalid HTTP status code: \(String(describing: statusCode))")
                    }
                    print("<== response body size:\(data.count)")
                    #if DEBUG
                    if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        let pretty = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
                        print("<== response json: \(pretty)")
                    }
                    #endif

                    // save cache
                    if let ttl = target.headers?["x-cache-ttl"], let duration = Int(ttl) {
                        await self.cache.set(key: target.cacheKey, value: data, ttl: Duration.seconds(duration))
                    }

                    return data
                }
            }
            for try await result in group {
                results.append(result)
            }
            return results
        }
    }
}

extension AlienTarget {
    var cacheKey: String {
        let string = [url, method.hashValue.asString, headers?.description, body?.hexString].compactMap { $0 }.joined()
        return SHA256.hash(data: Data(string.utf8)).description
    }
}
