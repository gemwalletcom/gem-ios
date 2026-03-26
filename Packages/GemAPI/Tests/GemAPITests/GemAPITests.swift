// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import Primitives
import SwiftHTTPClient
@testable import GemAPI

@Suite(.serialized)
struct GemAPITests {

    @Test
    func walletScopedRequestWaitsForPreflight() async throws {
        let events = RequestEvents()
        let assetIds = try await withMockURLProtocol(
            observer: { _ in
                events.record("request")
            }
        ) {
            let service = makeService(
                walletRequestPreflight: {
                    events.record("preflight-start")
                    try await Task.sleep(for: .milliseconds(20))
                    events.record("preflight-end")
                }
            )

            return try await service.getDeviceAssets(walletId: "wallet", fromTimestamp: 0)
        }

        #expect(assetIds.isEmpty)
        #expect(events.snapshot() == ["preflight-start", "preflight-end", "request"])
    }

    @Test
    func nonWalletScopedRequestSkipsPreflight() async throws {
        let events = RequestEvents()
        let names = try await withMockURLProtocol(
            observer: { _ in
                events.record("request")
            }
        ) {
            let service = makeService(
                responseBody: Data("[]".utf8),
                walletRequestPreflight: {
                    events.record("preflight")
                }
            )

            return try await service.getAddressNames(requests: [])
        }

        #expect(names.isEmpty)
        #expect(events.snapshot() == ["request"])
    }

    @Test
    func walletScopedPreflightFailurePreventsDispatch() async {
        let events = RequestEvents()
        await withMockURLProtocol(
            observer: { _ in
                events.record("request")
            }
        ) {
            let service = makeService(
                walletRequestPreflight: {
                    throw TestError.failed
                }
            )

            do {
                _ = try await service.getDeviceAssets(walletId: "wallet", fromTimestamp: 0)
                Issue.record("Expected preflight to throw")
            } catch {
                #expect(events.snapshot().isEmpty)
            }
        }
    }

    @Test
    func gemDeviceAPIWalletIdClassifiesWalletScopedTargets() {
        #expect(GemDeviceAPI.getSubscriptions.walletId == nil)
        #expect(GemDeviceAPI.getAssetsList(walletId: "wallet", fromTimestamp: 0).walletId == "wallet")
        #expect(GemDeviceAPI.getTransactions(walletId: "wallet", assetId: nil, fromTimestamp: 0).walletId == "wallet")
        #expect(GemDeviceAPI.getFiatQuoteUrl(walletId: "wallet", quoteId: "quote").walletId == "wallet")
    }
}

private extension GemAPITests {
    func withMockURLProtocol<T>(
        responseBody: Data = Data("[]".utf8),
        observer: @escaping @Sendable (URLRequest) -> Void = { _ in },
        _ body: () async throws -> T
    ) async rethrows -> T {
        MockURLProtocol.observer = observer
        MockURLProtocol.handler = { request in
            let url = try #require(request.url)
            let response = HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: [:]
            )!
            return (response, responseBody)
        }
        defer {
            MockURLProtocol.handler = nil
            MockURLProtocol.observer = nil
        }
        return try await body()
    }

    func makeService(
        responseBody: Data = Data("[]".utf8),
        walletRequestPreflight: (@Sendable () async throws -> Void)? = nil
    ) -> GemAPIService {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]

        let session = URLSession(configuration: configuration)
        return GemAPIService(
            provider: Provider<GemAPI>(session: session),
            deviceProvider: Provider<GemDeviceAPI>(session: session),
            walletRequestPreflight: walletRequestPreflight
        )
    }
}

private final class MockURLProtocol: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var handler: (@Sendable (URLRequest) throws -> (HTTPURLResponse, Data))?
    nonisolated(unsafe) static var observer: (@Sendable (URLRequest) -> Void)?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = Self.handler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }

        do {
            Self.observer?(request)
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

private final class RequestEvents: @unchecked Sendable {
    private let lock = NSLock()
    private var events: [String] = []

    func record(_ event: String) {
        lock.lock()
        defer { lock.unlock() }
        events.append(event)
    }

    func snapshot() -> [String] {
        lock.lock()
        defer { lock.unlock() }
        return events
    }
}

private enum TestError: Error {
    case failed
}
