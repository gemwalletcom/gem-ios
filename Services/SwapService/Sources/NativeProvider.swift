// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import ChainService
import Primitives

public actor NativeProvider {
    let session: URLSession
    let nodeProvider: any NodeURLFetchable

    init(
        session: URLSession = .shared,
        nodeProvider: any NodeURLFetchable
    ) {
        self.session = session
        self.nodeProvider = nodeProvider
    }
}

extension NativeProvider: AlienProvider {
    public func getEndpoint(chain: Gemstone.Chain) throws -> String {
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

extension AlienTarget: URLRequestConvertible {
    func asRequest() throws -> URLRequest {
        guard let url = URL(string: self.url) else {
            let error = AlienError.RequestError(msg: "invalid url: \(self.url)")
            throw error
        }
        var request = URLRequest(url: url)
        request.httpMethod = self.method.description
        if let headers = self.headers {
            request.allHTTPHeaderFields = headers
        }
        if let body = self.body {
            request.httpBody = body
        }
        return request
    }
}

protocol URLRequestConvertible {
    func asRequest() throws -> URLRequest
}

struct URLRequestSequence<T: URLRequestConvertible>: AsyncSequence {
    typealias Element = (Data, URLResponse)

    let requests: [T]
    let session: URLSession

    init(requests: [T], session: URLSession = .shared) {
        self.requests = requests
        self.session = session
    }

    struct AsyncRequestIterator: AsyncIteratorProtocol {
        var requests: [T].Iterator
        let session: URLSession

        mutating func next() async throws -> Element? {
            guard let request = requests.next() else {
                return nil
            }
            let req = try request.asRequest()
            #if DEBUG
            print("==> request: \(req)")
            if let body = req.httpBody {
                print("==> body: \(String(decoding: body, as: UTF8.self))")
            }
            #endif
            let tuple = try await session.data(for: request.asRequest())
            return tuple
        }
    }

    func makeAsyncIterator() -> AsyncRequestIterator {
        return AsyncRequestIterator(requests: requests.makeIterator(), session: session)
    }
}
