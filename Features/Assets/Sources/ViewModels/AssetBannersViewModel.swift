// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt

@Observable
@MainActor
public final class AssetBannersViewModel: Sendable {
    private let assetData: AssetData
    private let banners: [Banner]
    
    public init(
        assetData: AssetData,
        banners: [Banner]
    ) {
        self.assetData = assetData
        self.banners = banners
    }
    
    public var allBanners: [Banner] {
        activateAssetBanner + filteredBanners
    }
    
    // MARK: - Private
    
    private var filteredBanners: [Banner] {
        banners.filter { shouldShowBanner($0) }
    }
    
    private func shouldShowBanner(_ banner: Banner) -> Bool {
        switch banner.event {
        case .stake: assetData.balance.staked.isZero
        case .enableNotifications, .accountActivation, .accountBlockedMultiSignature, .activateAsset: true
        }
    }
    
    private var activateAssetBanner: [Banner] {
        guard !assetData.metadata.isActive else { return [] }
        
        return [Banner(
            wallet: .none,
            asset: assetData.asset,
            chain: .none,
            event: .activateAsset,
            state: .alwaysActive
        )]
    }
}
