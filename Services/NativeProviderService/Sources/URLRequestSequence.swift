// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone

protocol URLRequestConvertible {
    func asRequest() throws -> URLRequest
}

struct URLRequestSequence<T: URLRequestConvertible>: AsyncSequence {
    typealias Element = (Data, URLResponse)

    private let requests: [T]
    private let session: URLSession

    init(
        requests: [T],
        session: URLSession = .shared
    ) {
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
            return try await session.data(for: request.asRequest())
        }
    }

    func makeAsyncIterator() -> AsyncRequestIterator {
        return AsyncRequestIterator(requests: requests.makeIterator(), session: session)
    }
}

extension AlienTarget: URLRequestConvertible {
    func asRequest() throws -> URLRequest {
        guard let url = URL(string: self.url) else {
            let error = AlienError.RequestError(msg: "invalid url: \(self.url)")
            throw error
        }
        var request = URLRequest(url: url)
        request.httpMethod = alienMethodToString(method: self.method)
        if let headers = self.headers {
            request.allHTTPHeaderFields = headers
        }
        if let body = self.body {
            request.httpBody = body
        }
        return request
    }
}
