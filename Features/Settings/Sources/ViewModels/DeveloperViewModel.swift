// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Foundation
import Localization
import Preferences
import BannerService
import StakeService
import AssetsService
import TransactionsService
import Primitives

@MainActor
public struct DeveloperViewModel {
    private let transactionsService: TransactionsService
    private let assetService: AssetsService
    private let stakeService: StakeService
    private let bannerService: BannerService

    public init(
        transactionsService: TransactionsService,
        assetService: AssetsService,
        stakeService: StakeService,
        bannerService: BannerService
    ) {
        self.transactionsService = transactionsService
        self.assetService = assetService
        self.stakeService = stakeService
        self.bannerService = bannerService
    }

    var title: String {
        Localized.Settings.developer
    }
    
    var deviceId: String {
        (try? SecurePreferences().get(key: .deviceId)) ?? .empty
    }
    
    var deviceToken: String {
        (try? SecurePreferences().get(key: .deviceToken)) ?? .empty
    }
    
    func reset() {
        do {
            try clearDocuments()
            Preferences.standard.clear()
            try SecurePreferences.standard.clear()
            fatalError()
        } catch {
            NSLog("reset error \(error)")
        }
    }
    
    private func clearDocuments() throws {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        for fileURL in fileURLs {
            try FileManager.default.removeItem(at: fileURL)
        }
    }

    func clearCache() {
        URLCache.shared.removeAllCachedResponses()
    }
    
    // database
    
    func clearTransactions() {
        do {
            try transactionsService.transactionStore.clear()
        } catch { }
    }

    func clearPendingTransactions() {
        do {
            let transactionIds = try transactionsService.transactionStore.getTransactions(state: .pending).map { $0.id }
            try transactionsService.transactionStore.deleteTransactionId(ids: transactionIds)
        } catch { }
    }
    
    func clearAssets() {
        do {
            try assetService.assetStore.clearTokens()
        } catch { }
    }
    
    func clearDelegations() {
        do {
            try stakeService.clearDelegations()
        } catch { }
    }
    
    func clearValidators() {
        do {
            try stakeService.clearValidators()
        } catch { }
    }

    func clearBanners() {
        do {
            try bannerService.clearBanners()
        } catch { }
    }

    // preferences
    
    func clearAssetsVersion() {
        Preferences.standard.swapAssetsVersion = 0
    }
    
    func deeplink(deeplink: DeepLink) {
        Task {
            await UIApplication.shared.open(deeplink.localUrl, options: [:])
        }
    }
}
