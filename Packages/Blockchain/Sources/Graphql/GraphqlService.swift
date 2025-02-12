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
        let data = try await provider
            .request(.request(request))
            .mapOrError(as: GraphqlData<T>.self, asError: GraphqlError.self).data
        
        if let data {
            return data
        } else {
            throw AnyError("Unable to get data for query: \(request.query)")
        }
    }
    
    func request<T: Codable & Sendable>(_ request: GraphqlRequest) async throws -> GraphqlData<T> {
        try await provider.request(.request(request))
            .map(as: GraphqlData<T>.self)
    }
}

extension GraphqlError: LocalizedError {
    public var errorDescription: String? {
        message
    }
}
