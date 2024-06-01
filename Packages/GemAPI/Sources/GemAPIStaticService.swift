// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftHTTPClient
import Primitives

public struct GemAPIStaticService {
    
    let provider: Provider<GemAPIStatic>
    
    public static let shared = Provider<GemAPIStatic>()
    
    public init(
        provider: Provider<GemAPIStatic> = Self.shared
    ) {
        self.provider = provider
    }
    
    public func getValidators(chain: Chain) async throws -> [StakeValidator] {
        try await provider.request(.getValidators(chain: chain.rawValue))
            .map(as: [StakeValidator].self)
    }
}
