// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftHTTPClient

public actor WebSocketConnectionMock: WebSocketConnectable {

    private var continuation: AsyncStream<WebSocketEvent>.Continuation?
    private var sentData: [Data] = []

    public private(set) var state: WebSocketState = .disconnected

    public init() {}

    // MARK: - WebSocketConnectable

    public func connect() -> AsyncStream<WebSocketEvent> {
        AsyncStream { [weak self] continuation in
            guard let self else {
                continuation.finish()
                return
            }

            Task {
                await self.setupMockStream(continuation)
            }
        }
    }

    public func disconnect() async {
        state = .disconnected
        continuation?.yield(.disconnected(nil))
        continuation?.finish()
        continuation = nil
    }

    public func send(_ data: Data) async throws {
        guard state == .connected else {
            throw WebSocketError.notConnected
        }
        sentData.append(data)
    }

    // MARK: - Mock Control API

    public func simulateConnected() {
        state = .connected
        continuation?.yield(.connected)
    }

    public func simulateMessage(_ data: Data) {
        continuation?.yield(.message(data))
    }

    public func simulateDisconnect(error: Error? = nil) {
        state = .disconnected
        continuation?.yield(.disconnected(error))
    }

    public func getSentData() -> [Data] {
        sentData
    }

    public func clearSentData() {
        sentData.removeAll()
    }

    // MARK: - Private

    private func setupMockStream(_ continuation: AsyncStream<WebSocketEvent>.Continuation) {
        self.continuation = continuation
        state = .connecting
    }
}
