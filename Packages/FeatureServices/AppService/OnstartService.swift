// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives
import NodeService
import AssetsService
import Preferences
import WalletService
import UIKit

// OnstartService runs services before the app starts.
// See OnstartAsyncService for any background tasks to run after start
public struct OnstartService: Sendable {

    private let assetsService: AssetsService
    private let assetStore: AssetStore
    private let nodeStore: NodeStore
    private let preferences: Preferences
    private let walletService: WalletService

    public init(
        assetsService: AssetsService,
        assetStore: AssetStore,
        nodeStore: NodeStore,
        preferences: Preferences,
        walletService: WalletService
    ) {
        self.assetsService = assetsService
        self.assetStore = assetStore
        self.nodeStore = nodeStore
        self.preferences = preferences
        self.walletService = walletService
    }

    @MainActor
    public func configure() {
        validateDeviceSecurity()
        configureURLCache()
        excludeDirectoriesFromBackup()
        migrations()
        preferences.incrementLaunchesCount()

        #if DEBUG
        configureScreenshots()
        #endif
    }
}

// MARK: - Private

extension OnstartService {

    private func migrations() {
        do {
            try walletService.setup(chains: AssetConfiguration.allChains)
        } catch {
            debugLog("Setup chains: \(error)")
        }
        do {
            try ImportAssetsService(
                assetsService: assetsService,
                assetStore: assetStore,
                preferences: preferences
            ).migrate()
        } catch {
            debugLog("migrations error: \(error)")
        }

        if !preferences.hasCurrency, let currency = Locale.current.currency {
            preferences.currency = (Currency(rawValue: currency.identifier) ?? .usd).rawValue
        }
    }

    private func configureURLCache() {
        URLCache.shared.memoryCapacity = 256_000_000 // ~256 MB memory space
        URLCache.shared.diskCapacity = 1_000_000_000 // ~1GB disk cache space
    }

    private func excludeDirectoriesFromBackup() {
        do {
            let excludedBackupDirectories: [FileManager.Directory] = [.documents, .applicationSupport, .library(.preferences)]
            try excludedBackupDirectories.forEach {
                try FileManager.default.addSkipBackupAttributeToItemAtURL($0.url)

                #if DEBUG
                debugLog("Excluded backup directory: \($0.directory)")
                #endif
            }
        } catch {
            debugLog("addSkipBackupAttributeToItemAtURL error \(error)")
        }
    }

    @MainActor
    private func validateDeviceSecurity() {
        let device = UIDevice.current
        if !device.isSimulator && (device.isJailBroken || device.isFridaDetected) {
            fatalError()
        }
    }

    private func configureScreenshots() {
        if ProcessInfo.processInfo.environment["SCREENSHOTS_PATH"] != nil {
            if let currency = Locale.current.currency {
                Preferences.standard.currency = currency.identifier
            }
        }
    }
}
