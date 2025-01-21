// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GemAPI
import Store

public struct NFTService: Sendable {
    private let apiService: any GemAPINFTService
    private let nftStore: NFTStore
    
    public init(
        apiService: any GemAPINFTService = GemAPIService(),
        nftStore: NFTStore
    ) {
        self.apiService = apiService
        self.nftStore = nftStore
    }
    
    public func updateNFT(deviceId: String, wallet: Wallet) async throws {
        let nft = try await apiService.getNFTAssets(deviceId: deviceId, walletIndex: wallet.index.asInt)
        try nftStore.saveNFTData(nft, for: wallet.id)
    }
}
