// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Localization

struct DeveloperViewModel {
    
    let transactionsService: TransactionsService
    let assetService: AssetsService
    let stakeService: StakeService
    let bannerService: BannerService

    var title: String {
        return Localized.Settings.developer
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
            try stakeService.store.clearDelegations()
        } catch { }
    }
    
    func clearValidators() {
        do {
            try stakeService.store.clearValidators()
        } catch { }
    }
    

    func clearBanners() {
        let _ = try? bannerService.store.clear()
    }

    // preferences
    
    func clearAssetsVersion() {
        Preferences.standard.swapAssetsVersion = 0
    }
}
