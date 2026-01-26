// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import class Gemstone.Hyperliquid
import struct Gemstone.GemPerpetualBalance
import struct Gemstone.GemPerpetualPosition
import struct Gemstone.GemHyperliquidOpenOrder
import Primitives
import WebSocketClient

public actor HyperliquidObserverService: Sendable {

    private let perpetualService: HyperliquidPerpetualServiceable
    private let webSocket: any WebSocketConnectable
    private let hyperliquid = Hyperliquid()
    private let encoder = JSONEncoder()

    private var observeTask: Task<Void, Never>?
    private var currentWallet: Wallet?

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
                handleMessage(data)
            case .disconnected:
                break
            }
        }
    }

    private func handleConnected() async {
        guard let address = currentWallet?.hyperliquidAccount?.address else { return }
        do {
            try await perpetualService.updateMarkets()
            try await subscribeClearinghouseState(user: address)
            try await subscribeOpenOrders(user: address)
        } catch {
            debugLog("HyperliquidObserver: subscribe failed: \(error)")
        }
    }

    private func handleMessage(_ data: Data) {
        guard let walletId = currentWallet?.walletId else { return }

        do {
            switch try hyperliquid.parseWebsocketData(data: data) {
            case .clearinghouseState(let balance, let newPositions):
                try handleClearinghouseState(walletId: walletId, balance: balance, newPositions: newPositions)
            case .openOrders(let orders):
                try handleOpenOrders(walletId: walletId, orders: orders)
            case .subscriptionResponse(let subscriptionType):
                debugLog("HyperliquidObserver: subscribed to \(subscriptionType)")
            case .unknown:
                debugLog("HyperliquidObserver: unknown message")
            }
        } catch {
            debugLog("HyperliquidObserver: handle message error: \(error)")
        }
    }

    private func handleClearinghouseState(
        walletId: WalletId,
        balance: GemPerpetualBalance,
        newPositions: [GemPerpetualPosition]
    ) throws {
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

    private func handleOpenOrders(walletId: WalletId, orders: [GemHyperliquidOpenOrder]) throws {
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

    // MARK: - Subscriptions

    private func subscribeClearinghouseState(user: String) async throws {
        let request = HyperliquidRequest(
            method: .subscribe,
            subscription: .clearinghouseState(user: user)
        )
        try await webSocket.send(try encoder.encode(request).encodeString())
    }

    private func subscribeOpenOrders(user: String) async throws {
        let request = HyperliquidRequest(
            method: .subscribe,
            subscription: .openOrders(user: user)
        )
        try await webSocket.send(try encoder.encode(request).encodeString())
    }
}
