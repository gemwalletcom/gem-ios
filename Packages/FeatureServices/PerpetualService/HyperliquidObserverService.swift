// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import class Gemstone.Hyperliquid
import struct Gemstone.GemPerpetualBalance
import struct Gemstone.GemPerpetualPosition
import struct Gemstone.GemHyperliquidOpenOrder
import struct Gemstone.GemChartCandleStick
import Primitives
import WebSocketClient

public actor HyperliquidObserverService: Sendable {

    private let perpetualService: HyperliquidPerpetualServiceable
    private let webSocket: any WebSocketConnectable
    private let hyperliquid = Hyperliquid()
    private let encoder = JSONEncoder()

    private var observeTask: Task<Void, Never>?
    private var currentWallet: Wallet?

    public let chartService = HyperliquidChartService()

    public init(
        webSocket: any WebSocketConnectable = WebSocketConnection(url: Constants.hyperliquidWebSocketURL),
        perpetualService: HyperliquidPerpetualServiceable
    ) {
        self.webSocket = webSocket
        self.perpetualService = perpetualService
    }

    deinit {
        observeTask?.cancel()
    }

    // MARK: - Public API

    public func connect(for wallet: Wallet) async {
        guard currentWallet?.id != wallet.id else { return }

        await disconnect()
        currentWallet = wallet

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
        currentWallet = nil

        await webSocket.disconnect()
    }

    // MARK: - Private

    private func observeConnection() async {
        for await event in await webSocket.connect() {
            guard !Task.isCancelled else { break }

            switch event {
            case .connected:
                await handleConnected()
            case .message(let data):
                await handleMessage(data)
            case .disconnected:
                break
            }
        }
    }

    private func handleConnected() async {
        guard let address = currentWallet?.hyperliquidAccount?.address else { return }
        do {
            try await perpetualService.updateMarkets()
            try await send(HyperliquidRequest(method: .subscribe, subscription: .clearinghouseState(user: address)))
            try await send(HyperliquidRequest(method: .subscribe, subscription: .openOrders(user: address)))
        } catch {
            debugLog("HyperliquidObserver: subscribe failed: \(error)")
        }
    }

    private func handleMessage(_ data: Data) async {
        do {
            switch try hyperliquid.parseWebsocketData(data: data) {
            case .clearinghouseState(let balance, let newPositions):
                try handleClearinghouseState(balance: balance, newPositions: newPositions)
            case .openOrders(let orders):
                try handleOpenOrders(orders: orders)
            case .candle(let candle):
                try await handleCandle(candle: candle)
            case .allMids(let prices):
                try perpetualService.updatePrices(prices)
            case .subscriptionResponse(let subscriptionType):
                debugLog("HyperliquidObserver: subscription response - \(subscriptionType)")
            case .unknown:
                debugLog("HyperliquidObserver: unknown message: \(String(data: data, encoding: .utf8) ?? "nil")")
            }
        } catch {
            debugLog("HyperliquidObserver: handle message error: \(error)")
        }
    }

    private func handleClearinghouseState(
        balance: GemPerpetualBalance,
        newPositions: [GemPerpetualPosition]
    ) throws {
        guard let walletId = currentWallet?.walletId else { return }

        let diff = hyperliquid.diffClearinghousePositions(
            newPositions: newPositions,
            existingPositions: try perpetualService.getHypercorePositions(walletId: walletId)
        )

        try perpetualService.updateBalance(
            walletId: walletId,
            balance: balance
        )
        try perpetualService.diffPositions(
            deleteIds: diff.deletePositionIds,
            positions: diff.positions,
            walletId: walletId
        )
    }

    private func handleOpenOrders(orders: [GemHyperliquidOpenOrder]) throws {
        guard let walletId = currentWallet?.walletId else { return }

        let diff = hyperliquid.diffOpenOrdersPositions(
            orders: orders,
            existingPositions: try perpetualService.getHypercorePositions(walletId: walletId)
        )
        try perpetualService.diffPositions(
            deleteIds: diff.deletePositionIds,
            positions: diff.positions,
            walletId: walletId
        )
    }

    private func handleCandle(candle: GemChartCandleStick) async throws {
        await chartService.yield(try candle.map())
    }

    private func send(_ request: HyperliquidRequest) async throws {
        try await webSocket.send(try encoder.encode(request).encodeString())
    }
}

// MARK: - AllMids Subscriptions

extension HyperliquidObserverService {
    public func subscribeAllMids() async throws {
        try await send(HyperliquidRequest(method: .subscribe, subscription: .allMids))
    }

    public func unsubscribeAllMids() async throws {
        try await send(HyperliquidRequest(method: .unsubscribe, subscription: .allMids))
    }
}

// MARK: - Chart Subscriptions

extension HyperliquidObserverService {
    public func subscribeCandle(subscription: ChartSubscription) async throws {
        try await send(HyperliquidRequest(method: .subscribe, subscription: .candle(coin: subscription.coin, interval: subscription.interval)))
    }

    public func unsubscribeCandle(subscription: ChartSubscription) async throws {
        try await send(HyperliquidRequest(method: .unsubscribe, subscription: .candle(coin: subscription.coin, interval: subscription.interval)))
    }
}
