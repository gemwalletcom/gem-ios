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
import BigInt

@MainActor
public struct DeveloperViewModel {
    private let walletId: WalletId
    private let transactionsService: TransactionsService
    private let assetService: AssetsService
    private let stakeService: StakeService
    private let bannerService: BannerService

    public init(
        walletId: WalletId,
        transactionsService: TransactionsService,
        assetService: AssetsService,
        stakeService: StakeService,
        bannerService: BannerService
    ) {
        self.walletId = walletId
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
    
    func addTransactions() {
        let solAddress = "7nVDzZUjrBA3gHs3gNcHidhmR96CH7KpKsU8pyBZGHUr"
        let ethAddress = "0xf1158986419F6058231b0Dbd7A78Ff0674ebBc50"
        let btcAddress = "bc1q4jwwsy7txnzsr7w53j4wnrg6rrnmj86a47e2t9"
        let trxAddress = "TAw8sw21A3pGDCtHGuB55BGDqLVHQTYwAC"
        let data: [(direction: TransactionDirection, from: String, to: String, assetId: AssetId, transactionType: TransactionType, value: BigInt, metadata: TransactionMetadata?, createdAt: Date)] = [
            (.incoming, solAddress, "", AssetId(chain: .solana), .transfer, BigInt(111111111), .none, createdAt: Date().addingTimeInterval(-1)),
            (.outgoing, "", solAddress, AssetId(chain: .solana), .transfer, BigInt(3311111111), .none, createdAt: Date().addingTimeInterval(-2)),
            (
                .selfTransfer,
                "",
                "",
                AssetId(chain: .sui),
                .swap,
                BigInt(76767623311111111),
                TransactionMetadata
                    .swap(
                        TransactionSwapMetadata(
                            fromAsset: AssetId.init(chain: .sui),
                            fromValue: BigInt(2767611111).description,
                            toAsset: AssetId.init(chain: .solana),
                            toValue: BigInt(812312312).description,
                            provider: .none
                        )
                    ),
                createdAt: Date().addingTimeInterval(-122223)
            ),
            (
                .incoming,
                trxAddress,
                "",
                AssetId(chain: .tron),
                .transfer,
                BigInt(912312312),
                .none,
                createdAt: Date().addingTimeInterval(-122224)
            ),
            (
                .outgoing,
                "",
                ethAddress,
                AssetId(chain: .ethereum),
                .transfer,
                BigInt(76767623311111111),
                .none,
                createdAt: Date().addingTimeInterval(-1344411)
            ),
            (
                .incoming,
                btcAddress,
                "",
                AssetId(chain: .bitcoin),
                .transfer,
                BigInt(621111111),
                .none,
                createdAt: Date().addingTimeInterval(-100)
            ),
            (
                .incoming,
                btcAddress,
                "",
                AssetId(chain: .bitcoin),
                .transfer,
                BigInt(46161111),
                .none,
                createdAt: Date().addingTimeInterval(-10000)
            ),
            (
                .incoming,
                btcAddress,
                "",
                AssetId(chain: .bitcoin),
                .transfer,
                BigInt(72312312),
                .none,
                createdAt: Date().addingTimeInterval(-1344401)
            ),
            (
                .selfTransfer,
                "",
                "",
                AssetId(chain: .ethereum),
                .swap,
                BigInt(76767623311111111),
                TransactionMetadata
                    .swap(
                        TransactionSwapMetadata(
                            fromAsset: AssetId.init(chain: .ethereum),
                            fromValue: BigInt(276767623311111111).description,
                            toAsset: AssetId.init(chain: .bitcoin),
                            toValue: BigInt(32312312).description,
                            provider: .none
                        )
                    ),
                createdAt: Date().addingTimeInterval(-1344411)
            ),
            (
                .incoming,
                "",
                "",
                AssetId(chain: .smartChain),
                .stakeRewards,
                BigInt(464222222272312312),
                .none,
                createdAt: Date().addingTimeInterval(-1444401)
            ),
            (
                .incoming,
                "",
                "NodeReal",
                AssetId(chain: .smartChain),
                .stakeDelegate,
                BigInt("54213322222272312312"),
                .none,
                createdAt: Date().addingTimeInterval(-1464401)
            ),
        ]
        
        let transactions = data.enumerated().map { (index, element) in
            Transaction(
                id: "\(element.assetId.chain.rawValue)_\(index)" ,
                hash: index.description,
                assetId: element.assetId,
                from: element.from,
                to: element.to,
                contract: .none,
                type: element.transactionType,
                state: .confirmed,
                blockNumber: .zero,
                sequence: .zero,
                fee: .zero,
                feeAssetId: element.assetId,
                value: element.value.description,
                memo: .none,
                direction: element.direction,
                utxoInputs: [],
                utxoOutputs: [],
                metadata: element.metadata,
                createdAt: element.createdAt
            )
        }
        try? transactionsService.transactionStore.addTransactions(walletId: walletId.id, transactions: transactions)
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
