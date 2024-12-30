// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftHTTPClient
import BigInt

public struct GraphqlService: Sendable {
    
    let provider: Provider<GraphqlProvider>
    
    public init(
        provider: Provider<GraphqlProvider>
    ) {
        self.provider = provider
    }
    
    func requestData<T: Codable & Sendable>(_ request: GraphqlRequest) async throws -> T {
        try await provider.request(.request(request))
            .mapOrError(as: GraphqlData<T>.self, asError: GraphqlError.self).data
    }
}

extension GraphqlError: LocalizedError {
    public var errorDescription: String? {
        message
    }
}
