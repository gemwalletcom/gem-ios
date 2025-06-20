import Foundation
import Gemstone
@testable import NativeProviderService
import Testing

@Test func uRLError() async throws {
    let config = URLSessionConfiguration.ephemeral
    MockURLProtocol.error = NSError(domain: NSURLErrorDomain, code: -1)
    config.protocolClasses = [MockURLProtocol.self]

    let session = URLSession(configuration: config)
    let nodeProvider = MockNodeURL(url: URL(string: "/")!)

    let provider = NativeProvider(
        session: session,
        nodeProvider: nodeProvider
    )

    await #expect(throws: AlienError.self, performing: {
        let target = AlienTarget(url: "/", method: .get, headers: nil, body: nil)
        _ = try await provider.request(target: target)
    })
}
