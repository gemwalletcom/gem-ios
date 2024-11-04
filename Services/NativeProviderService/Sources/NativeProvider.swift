// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import ChainService
import Primitives

public actor NativeProvider {
    let session: URLSession
    let nodeProvider: any NodeURLFetchable

    public init(
        session: URLSession = .shared,
        nodeProvider: any NodeURLFetchable
    ) {
        self.session = session
        self.nodeProvider = nodeProvider
    }
}

extension NativeProvider: AlienProvider {
    nonisolated public func getEndpoint(chain: Gemstone.Chain) throws -> String {
        self.nodeProvider.node(for: Primitives.Chain(rawValue: chain)!).absoluteString
    }

    public func request(targets: [AlienTarget]) async throws -> [Data] {
        return try await withThrowingTaskGroup(of: Data.self) { group in
            var results = [Data]()

            for target in targets {
                group.addTask {
                    print("==> handle request:\n\(target)")
                    let (data, response) = try await self.session.data(for: target.asRequest())
                    if (response as? HTTPURLResponse)?.statusCode != 200 {
                        throw AlienError.ResponseError(msg: "invalid response: \(response)")
                    }
                    print("<== response:\n\(String(decoding: data, as: UTF8.self))")
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


