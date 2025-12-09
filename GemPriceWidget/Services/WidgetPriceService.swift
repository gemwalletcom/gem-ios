// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import GemAPI
import WidgetKit
import Preferences
import Style

internal struct WidgetPriceService {
    private let pricesService: any GemAPIPricesService
    private let assetsService: any GemAPIAssetsService
    private let preferences = SharedPreferences()

    init() {
        self.pricesService = GemAPIService()
        self.assetsService = GemAPIService()
    }

    internal func coins(_ widgetFamily: WidgetFamily) -> [AssetId] {
        switch widgetFamily {
        case .systemSmall:
            [AssetId(chain: .bitcoin, tokenId: nil)]
        default:
            [
                AssetId(chain: .bitcoin, tokenId: nil),
                AssetId(chain: .ethereum, tokenId: nil),
                AssetId(chain: .solana, tokenId: nil),
                AssetId(chain: .xrp, tokenId: nil),
                AssetId(chain: .smartChain, tokenId: nil),
            ]
        }
    }

    internal func fetchTopCoinPrices(widgetFamily: WidgetFamily = .systemMedium) async -> PriceWidgetEntry {
        let coins = coins(widgetFamily)
        let currency = preferences.currency

        do {
            let (assets, prices) = try await (
                assetsService.getAssets(assetIds: coins),
                pricesService.getPrices(currency: currency, assetIds: coins)
            )

            return PriceWidgetEntry(
                date: Date(),
                coinPrices: await coinPrices(assets: assets, prices: prices),
                currency: currency,
                widgetFamily: widgetFamily
            )
        } catch {
            return PriceWidgetEntry.error(error: error.localizedDescription, widgetFamily: widgetFamily)
        }
    }
}

// MARK: - Private

extension WidgetPriceService {
    private func coinPrices(assets: [AssetBasic], prices: [AssetPrice]) async -> [CoinPrice] {
        await withTaskGroup(of: CoinPrice?.self) { group in
            for asset in assets {
                guard let assetPrice = prices.first(where: { $0.assetId == asset.asset.id }) else { continue }
                group.addTask {
                    CoinPrice(
                        assetId: asset.asset.id,
                        name: asset.asset.name,
                        symbol: asset.asset.symbol,
                        price: assetPrice.price,
                        priceChangePercentage24h: assetPrice.priceChangePercentage24h,
                        image: await Self.image(for: asset.asset.id)
                    )
                }
            }
            return await group.compactMap { $0 }.reduce(into: []) { $0.append($1) }
        }
    }

    private static func image(for assetId: AssetId) async -> Image? {
        switch assetId.type {
        case .native: Images.name(assetId.chain.rawValue)
        case .token: await fetchRemoteImage(url: AssetImageFormatter.shared.getURL(for: assetId))
        }
    }

    private static func fetchRemoteImage(url: URL) async -> Image? {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let uiImage = UIImage(data: data) else {
                throw AnyError("wrong image format")
            }
            return Image(uiImage: uiImage)
        } catch {
            debugLog("WidgetPriceService: Failed to fetch image from \(url): \(error)")
            return nil
        }
    }
}
