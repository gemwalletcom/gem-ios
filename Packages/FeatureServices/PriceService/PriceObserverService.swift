// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Preferences
import Primitives
import WebSocketClient
import GemAPI

public actor PriceObserverService: Sendable {
    private let priceService: PriceService
    private let preferences: Preferences
    private let securePreferences: SecurePreferences
    private let encoder = JSONEncoder()
    private let decoder = JSONDateDecoder.standard

    private var webSocket: any WebSocketConnectable
    private var observeTask: Task<Void, Never>?
    private var subscribedAssetIds: Set<AssetId> = []
    private var currentWalletId: WalletId?

    private init(
        priceService: PriceService,
        preferences: Preferences,
        securePreferences: SecurePreferences = SecurePreferences(),
        socket: any WebSocketConnectable
    ) {
        self.priceService = priceService
        self.preferences = preferences
        self.securePreferences = securePreferences
        self.webSocket = socket
    }

    public init(
        priceService: PriceService,
        preferences: Preferences,
        securePreferences: SecurePreferences = SecurePreferences()
    ) {
        let requestProvider = AuthenticatedRequestProvider(securePreferences: securePreferences)
        let configuration = WebSocketConfiguration(requestProvider: requestProvider)
        self.init(
            priceService: priceService,
            preferences: preferences,
            securePreferences: securePreferences,
            socket: WebSocketConnection(configuration: configuration)
        )
    }

    public init(
        priceService: PriceService,
        preferences: Preferences,
        securePreferences: SecurePreferences = SecurePreferences(),
        webSocket: any WebSocketConnectable
    ) {
        self.init(
            priceService: priceService,
            preferences: preferences,
            securePreferences: securePreferences,
            socket: webSocket
        )
    }

    deinit {
        observeTask?.cancel()
    }

    // MARK: - Public API

    public func connect() {
        guard observeTask == nil else { return }

        observeTask = Task { [weak self] in
            guard let self else { return }
            await self.observeConnection()
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
        let message = StreamMessage.addPrices(StreamMessagePrices(assets: newAssets))
        try await sendMessage(message)
        subscribedAssetIds.formUnion(newAssets)
    }

    func subscribeAssets() -> Set<AssetId> {
        return subscribedAssetIds
    }

    public func setupAssets(walletId: WalletId) async throws {
        currentWalletId = walletId
        let assets = try priceService.observableAssets(walletId: walletId)
        let message = StreamMessage.subscribePrices(StreamMessagePrices(assets: assets))
        try await sendMessage(message)
        subscribedAssetIds = Set(assets)
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
        guard let walletId = currentWalletId else { return }
        do {
            try await setupAssets(walletId: walletId)
        } catch {
            debugLog("price observer: setupAssets failed: \(error)")
        }
    }

    private func handleMessage(_ data: Data) {
        do {
            let event = try decoder.decode(StreamEvent.self, from: data)
            switch event {
            case .prices(let payload):
                debugLog("price observer: prices: \(payload.prices.count), rates: \(payload.rates.count)")
                try priceService.addRates(payload.rates)
                try priceService.updatePrices(payload.prices, currency: preferences.currency)
            case .balances(let updates):
                debugLog("price observer: balance updates: \(updates.count)")
            case .transactions(let update):
                debugLog("price observer: transactions for wallet \(update.walletId): \(update.transactions.count)")
            case .priceAlerts, .nft, .perpetual, .inAppNotification:
                break
            }
        } catch {
            debugLog("price observer: handleMessage error: \(error)")
        }
    }

    private func sendMessage(_ message: StreamMessage) async throws {
        let data = try encoder.encode(message)
        try await webSocket.send(data)
        
        debugLog("price observer send message: \(message)")
    }
}
