// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemAPI
import Store
import DeviceService

public struct NFTService: Sendable {
    private let apiService: any GemAPINFTService
    private let nftStore: NFTStore
    private let deviceService: any DeviceServiceable
    
    public init(
        apiService: any GemAPINFTService = GemAPIService(),
        nftStore: NFTStore,
        deviceService: any DeviceServiceable
    ) {
        self.apiService = apiService
        self.nftStore = nftStore
        self.deviceService = deviceService
    }
    
    public func updateAssets(wallet: Wallet) async throws -> Int {
        let deviceId = try await deviceService.getSubscriptionsDeviceId()
        let nfts = try await apiService.getNFTAssets(deviceId: deviceId, walletIndex: wallet.index.asInt)
        try nftStore.save(nfts, for: wallet.id)
        return nfts.count
    }
}
