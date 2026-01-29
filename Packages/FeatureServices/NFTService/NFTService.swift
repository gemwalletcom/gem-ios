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
        let nfts = try await apiService.getDeviceNFTAssets(deviceId: deviceId, walletId: try wallet.walletIdentifier().id)
        try nftStore.save(nfts, for: wallet.walletId)
        return nfts.count
    }

    public func report(collectionId: String, assetId: String?, reason: String?) async throws {
        let report = ReportNft(
            deviceId: try deviceService.getDeviceId(),
            collectionId: collectionId,
            assetId: assetId,
            reason: reason
        )
        try await apiService.reportNft(report)
    }
}
