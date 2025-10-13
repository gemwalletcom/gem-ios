// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt
import PrimitivesComponents

@Observable
@MainActor
public final class AssetSceneBannersViewModel: Sendable {
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
        (extraBanners + banners)
            .filter { shouldShowBanner($0) }
            .sorted { $0 < $1 }
    }
    
    // MARK: - Private

    private var extraBanners: [Banner] {
        [
            .activateAssetBanner(assetData.asset),
            .suspiciousAssetBanner()
        ]
    }

    private func shouldShowBanner(_ banner: Banner) -> Bool {
        switch banner.event {
        case .enableNotifications, .accountBlockedMultiSignature: true
        case .accountActivation: assetData.balance.available == 0
        case .stake: assetData.balance.staked.isZero && assetData.balance.frozen.isZero
        case .activateAsset: !assetData.metadata.isActive
        case .suspiciousAsset: AssetScoreTypeViewModel(score: assetData.metadata.rankScore).shouldShowBanner
        case .onboarding: false
        }
    }
}

extension Banner {
    static func activateAssetBanner(_ asset: Asset) -> Banner {
        Banner(
            wallet: .none,
            asset: asset,
            chain: .none,
            event: .activateAsset,
            state: .alwaysActive
        )
    }
    
    static func suspiciousAssetBanner() -> Banner {
        Banner(
            wallet: .none,
            asset: .none,
            chain: .none,
            event: .suspiciousAsset,
            state: .alwaysActive
        )
    }
}
