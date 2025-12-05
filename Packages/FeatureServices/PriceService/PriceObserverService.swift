// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Preferences
import SwiftHTTPClient

public actor PriceObserverService: Sendable {

    private let priceService: PriceService
    private let preferences: Preferences
    private let webSocket: any WebSocketConnectable
    private let encoder = JSONEncoder()
    private let decoder = JSONDateDecoder.standard

    private var observeTask: Task<Void, Never>?
    private var subscribedAssetIds: Set<AssetId> = []

    public init(
        webSocket: any WebSocketConnectable = WebSocketConnection(url: Constants.pricesWebSocketURL),
        priceService: PriceService,
        preferences: Preferences
    ) {
        self.webSocket = webSocket
        self.priceService = priceService
        self.preferences = preferences
    }

    deinit {
        observeTask?.cancel()
    }

    // MARK: - Public API

    public func connect() {
        guard observeTask == nil else { return }

        observeTask = Task { [weak self] in
            guard let self else { return }
            await observeConnection()
        }
    }

    public func disconnect() async {
        guard observeTask != nil else { return }

        observeTask?.cancel()
        observeTask = nil

        await webSocket.disconnect()
    }

    public func addAssets(assets: [AssetId]) async throws {
        let newAssets = Set(assets).subtracting(subscribedAssetIds).asArray()
        guard newAssets.isNotEmpty else {
            return
        }
        let action = WebSocketPriceAction(
            action: .add,
            assets: newAssets
        )
        try await sendAction(action)
        subscribedAssetIds.formUnion(newAssets)
    }

    public func subscribeAssets() -> Set<AssetId> {
        return subscribedAssetIds
    }

    public func setupAssets() async throws {
        let assets = try priceService.observableAssets()
        let action = WebSocketPriceAction(
            action: .subscribe,
            assets: assets
        )
        try await sendAction(action)
        subscribedAssetIds.formUnion(assets)
    }

    // MARK: - Private

    private func observeConnection() async {
        for await event in await webSocket.connect() {
            guard !Task.isCancelled else { break }

            switch event {
            case .connected: await handleConnected()
            case .message(let data): handleMessage(data)
            case .disconnected: break
            }
        }
    }

    private func handleConnected() async {
        do {
            try await setupAssets()
        } catch {
            debugLog("price observer: setupAssets failed: \(error)")
        }
    }

    private func handleMessage(_ data: Data) {
        do {
            let payload = try decoder.decode(WebSocketPricePayload.self, from: data)

            debugLog("price observer: prices: \(payload.prices.count), rates: \(payload.rates.count)")

            try priceService.addRates(payload.rates)
            try priceService.updatePrices(payload.prices, currency: preferences.currency)
        } catch {
            debugLog("price observer: handleMessage error: \(error)")
        }
    }

    private func sendAction(_ action: WebSocketPriceAction) async throws {
        let data = try encoder.encode(action)
        try await webSocket.send(data)
        debugLog("price observer: action \(action.action.rawValue), assets: \(action.assets?.count ?? 0)")
    }
}
