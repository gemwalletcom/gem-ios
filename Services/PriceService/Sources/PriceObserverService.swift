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
    private var isConnecting = false
    private var reconnectDelay: TimeInterval = 1
    private let maxReconnectDelay: TimeInterval = 30
    private var subscribedAssetIds: Set<AssetId> = []
    
    public init(
        endpoint: String = "wss://api.gemwallet.com/v1/ws/prices",
        priceService: PriceService,
        preferences: Preferences
    ) {
        guard let url = URL(string: endpoint) else {
            fatalError("Invalid WebSocket URL")
        }
        self.url = url
        self.session = .init(configuration: .default)

        self.priceService = priceService
        self.preferences = preferences
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
        isConnecting = false
        task?.cancel(with: .goingAway, reason: nil)
        task = nil
    }

    public func addAssets(assets: [AssetId]) throws {
        if subscribedAssetIds.contains(where: assets.contains) {
            return
        }
        let action = WebSocketPriceAction(
            action: .add,
            assets: assets
        )
        try sendAction(action)
        subscribedAssetIds.formUnion(assets)
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
            NSLog("startWebSocket \(error)")
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
                    NSLog("list error: \(error)")
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

            print("WebSocket receive error:", error)
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
        let payload = try JSONDecoder().decode(WebSocketPricePayload.self, from: data)
        
        NSLog("handlePayload prices: \(payload.prices.count), rates: \(payload.rates.count)")
        
        try priceService.addRates(payload.rates)
        try priceService.updatePrices(payload.prices, currency: preferences.currency)
    }

    private func scheduleReconnect() async {
        // Tear down current connection
        task?.cancel(with: .goingAway, reason: nil)
        task = nil

        // Bail if user called disconnect()
        guard isConnecting else { return }

        let delay = reconnectDelay
        reconnectDelay = min(maxReconnectDelay, reconnectDelay * 2)
        print("⚡️ Reconnecting in \(delay)s…")

        // Wait, then restart
        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        guard isConnecting else { return }
        startWebSocket()
    }
}
