// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public actor WebSocketConnection: WebSocketConnectable {

    public private(set) var state: WebSocketState = .disconnected

    private let configuration: WebSocketConfiguration
    private let session: URLSession

    private var task: URLSessionWebSocketTask?
    private var reconnectTask: Task<Void, Never>?
    private var continuation: AsyncStream<WebSocketEvent>.Continuation?
    private var reconnectDelay: TimeInterval

    public init(configuration: WebSocketConfiguration) {
        self.configuration = configuration
        self.session = URLSession(configuration: configuration.sessionConfiguration)
        self.reconnectDelay = configuration.reconnectDelay
    }

    public init(url: URL) {
        self.init(configuration: WebSocketConfiguration(url: url))
    }

    deinit {
        task?.cancel(with: .goingAway, reason: nil)
        reconnectTask?.cancel()
        continuation?.finish()
    }

    // MARK: - Public

    public func connect() -> AsyncStream<WebSocketEvent> {
        AsyncStream { [weak self] continuation in
            guard let self else {
                continuation.finish()
                return
            }

            Task {
                await self.setupStream(continuation)
            }
        }
    }

    public func disconnect() async {
        state = .disconnected

        cancelReconnect()
        cancelTask()

        continuation?.yield(.disconnected(nil))
        continuation?.finish()
        continuation = nil
    }

    public func send(_ data: Data) async throws {
        guard let task, state == .connected else {
            throw WebSocketError.notConnected
        }
        try await task.send(.data(data))
    }

    // MARK: - Private

    private func cancelTask() {
        task?.cancel(with: .goingAway, reason: nil)
        task = nil
    }

    private func cancelReconnect() {
        reconnectTask?.cancel()
        reconnectTask = nil
    }

    private func setupStream(_ continuation: AsyncStream<WebSocketEvent>.Continuation) {
        self.continuation = continuation

        continuation.onTermination = { [weak self] _ in
            Task {
                await self?.handleStreamTermination()
            }
        }

        startConnection()
    }

    private func handleStreamTermination() {
        guard state != .disconnected else { return }

        cancelTask()
        cancelReconnect()

        state = .disconnected
    }

    private func startConnection() {
        state = .connecting

        task = session.webSocketTask(with: configuration.url)
        task?.resume()

        state = .connected
        reconnectDelay = configuration.reconnectDelay
        continuation?.yield(.connected)

        listen()
    }

    private func listen() {
        task?.receive { [weak self] result in
            Task {
                await self?.handleReceive(result)
            }
        }
    }

    private func handleReceive(_ result: Result<URLSessionWebSocketTask.Message, Error>) {
        switch result {
        case .success(let message):
            reconnectDelay = configuration.reconnectDelay
            handleMessage(message)
            listen()

        case .failure(let error):
            handleError(error)
        }
    }

    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        guard let data = message.data else { return }
        continuation?.yield(.message(data))
    }

    private func handleError(_ error: Error) {
        guard state != .disconnected else { return }

        if let urlError = error as? URLError, urlError.code == .cancelled {
            return
        }

        scheduleReconnect(with: error)
    }

    private func scheduleReconnect(with error: Error?) {
        guard reconnectTask == nil else { return }

        cancelTask()

        guard state != .disconnected else { return }

        state = .reconnecting
        continuation?.yield(.disconnected(error))

        let delay = reconnectDelay
        reconnectDelay = min(configuration.maxReconnectDelay, reconnectDelay * 2)

        reconnectTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(delay))
            await self?.finishReconnect()
        }
    }

    private func finishReconnect() {
        reconnectTask = nil

        guard state == .reconnecting, task == nil else { return }

        startConnection()
    }
}
