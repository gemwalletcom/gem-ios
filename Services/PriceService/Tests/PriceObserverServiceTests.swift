// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import PriceService
import PriceServiceTestKit

struct PriceObserverServiceTests {

    @Test func addAssets() async throws {
        let service = PriceObserverService(priceService: .mock(), preferences: .mock())
        
        await #expect(service.subscribeAssets().isEmpty)
        
        try await service.addAssets(assets: [.mockSolana(), .mockSolanaUSDC()])
        
        await #expect(service.subscribeAssets().count == 2)
    }
}
