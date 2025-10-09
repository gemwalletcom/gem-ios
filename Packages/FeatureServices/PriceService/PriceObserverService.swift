// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Preferences

public actor PriceObserverService: Sendable {

    private let priceService: PriceService
    private let preferences: Preferences

    // MARK: – Configuration
    private let url: URL
    private let session: URLSession

    // MARK: – State
    private var task: URLSessionWebSocketTask?
    private var reconnectTask: Task<Void, Never>?
    private var isConnecting = false

    private var reconnectDelay: TimeInterval = 1
    private let maxReconnectDelay: TimeInterval = 30
    private var subscribedAssetIds: Set<AssetId> = []

    public init(
        url: URL = URL(string: "wss://api.gemwallet.com/v1/ws/prices")!,
        priceService: PriceService,
        preferences: Preferences
    ) {
        self.url = url
        self.session = .init(configuration: .default)

        self.priceService = priceService
        self.preferences = preferences
    }

    deinit {
        task?.cancel(with: .goingAway, reason: nil)
        reconnectTask?.cancel()
    }

    // MARK: – Public API

    /// Starts (or restarts) the WebSocket connection.
    public func connect() {
        guard !isConnecting else { return }
        isConnecting = true
        reconnectDelay = 1
        startWebSocket()
    }

    /// Cancels the connection and prevents further reconnects.
    public func disconnect() {
        guard isConnecting else { return }
        reconnectTask?.cancel()
        reconnectTask = nil
        task?.cancel(with: .goingAway, reason: nil)
        task = nil
        isConnecting = false
    }

    public func addAssets(assets: [AssetId]) throws {
        let newAssets = Set(assets).subtracting(subscribedAssetIds).asArray()
        guard newAssets.isNotEmpty else {
            return
        }
        let action = WebSocketPriceAction(
            action: .add,
            assets: newAssets
        )
        try sendAction(action)
        subscribedAssetIds.formUnion(newAssets)
    }

    public func subscribeAssets() -> Set<AssetId> {
        return subscribedAssetIds
    }

    public func setupAssets() throws {
        let assets = try priceService.observableAssets()
        let action = WebSocketPriceAction(
            action: .subscribe,
            assets: assets
        )
        try sendAction(action)
        subscribedAssetIds.formUnion(assets)
    }

    public func sendAction(_ action: WebSocketPriceAction) throws {
        let data = try JSONEncoder().encode(action)
        task?.send(.data(data)) { error in
            if let error {
                print("Price Observer WebSocket send error:", error)
                Task { await self.scheduleReconnect() }
            } else {
                print("Price Observer action \(action.action.rawValue), assets: \(action.assets?.count ?? 0)")
            }
        }
    }

    // MARK: – Private

    private func startWebSocket() {
        // Always build a fresh task
        task = session.webSocketTask(with: url)
        task?.resume()

        do {
            try setupAssets()
        } catch {
            NSLog("price observer: startWebSocket \(error)")
        }

        // Begin receiving
        listen()
    }

    private func listen() {
        task?.receive { result in
            // Dispatch back into the actor to process safely
            Task {
                do {
                    try await self.process(result)
                } catch {
                    NSLog("price observer: listen error: \(error)")
                }
            }
        }
    }

    private func process(_ result: Result<URLSessionWebSocketTask.Message, Error>) async throws {
        switch result {
        case .failure(let error):
            // If we've intentionally called disconnect(), do nothing
            guard isConnecting else { return }

            // Ignore cancellation errors
            if let urlErr = error as? URLError, urlErr.code == .cancelled {
                return
            }

            print("price observer:: process error:", error)
            await scheduleReconnect()

        case .success(let message):
            // Reset back-off on first successful receive
            reconnectDelay = 1

            try handle(message)
            listen()
        }
    }

    private func handle(_ message: URLSessionWebSocketTask.Message) throws {
        switch message {
        case .string(let text):
            try handleMessageData(data: try text.encodedData())
        case .data(let data):
            try handleMessageData(data: data)
        @unknown default:
            break
        }
    }

    private func handleMessageData(data: Data) throws {
        let payload = try JSONDateDecoder.standard.decode(WebSocketPricePayload.self, from: data)

        NSLog("price observer: prices: \(payload.prices.count), rates: \(payload.rates.count)")

        try priceService.addRates(payload.rates)
        try priceService.updatePrices(payload.prices, currency: preferences.currency)
    }

    private func scheduleReconnect() async {
        // already waiting
        guard reconnectTask == nil else { return }

        // Tear down current connection
        task?.cancel(with: .goingAway, reason: nil)
        task = nil

        // Bail if user called disconnect()
        guard isConnecting else { return }

        let delay = reconnectDelay
        reconnectDelay = min(maxReconnectDelay, reconnectDelay * 2)
        print("price observer: ⚡️ Reconnecting in \(delay)s…")

        // Wait, then restart
        reconnectTask = Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(for: .seconds(delay))
            await self.finishReconnect()
        }
    }

    private func finishReconnect() {
        reconnectTask = nil
        guard isConnecting, task == nil else { return }
        startWebSocket()
    }
}
