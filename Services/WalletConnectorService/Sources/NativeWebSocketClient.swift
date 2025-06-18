import Foundation
@preconcurrency import WalletConnectRelay

public actor NativeWebSocketClient: WebSocketConnecting {
    public nonisolated(unsafe) var onConnect: (() -> Void)?
    public nonisolated(unsafe) var onDisconnect: ((Error?) -> Void)?
    public nonisolated(unsafe) var onText: ((String) -> Void)?
    
    public nonisolated(unsafe) var request: URLRequest
    public nonisolated(unsafe) private(set) var isConnected: Bool = false
    
    private var socket: URLSessionWebSocketTask?
    private let session: URLSession
    private var receiveTask: Task<Void, Never>?
    
    private var reconnectTask: Task<Void, Never>?
    private var reconnectDelay: TimeInterval = 1
    private let maxReconnectDelay: TimeInterval = 30
    
    private var pingTask: Task<Void, Never>?
    private let pingInterval: TimeInterval = 25
    
    public init(
        request: URLRequest,
        session: URLSession = URLSession(configuration: .ephemeral)
    ) {
        self.request = request
        self.session = session
    }
    
    deinit {
        Task { [weak self] in await self?.shutdown(error: nil) }
    }
    
    public nonisolated func connect() {
        Task { await startConnection() }
    }
    
    public nonisolated func disconnect() {
        Task { await shutdown(error: nil) }
    }
    
    public nonisolated func write(
        string: String,
        completion: (@Sendable () -> Void)? = nil
    ) {
        Task { [weak self] in
            guard let self else { return }
            do {
                try await self.send(text: string)
                if let completion {
                    completion()
                }
            } catch {
                await self.shutdown(error: error)
            }
        }
    }
    
    private func startConnection() {
        guard !isConnected else { return }
        makeSocket()
        isConnected = true
        pingTask = Task { await pingLoop() }
    }
    
    
    private func shutdown(error: Error?) async {
        guard isConnected else { return }
        isConnected = false
        
        cancelPing()
        cancelReceive()
        cancelSocket()
        
        onDisconnect?(error)
        if error != nil {
            scheduleReconnect()
        }
    }
    
    private func send(text: String) async throws {
        guard isConnected, let socket else { throw URLError(.notConnectedToInternet) }
        try await socket.send(.string(text))
    }
    
    private func receiveLoop() async {
        do {
            while isConnected {
                guard let socket else { throw URLError(.notConnectedToInternet) }

                switch try await socket.receive() {
                case .string(let text):
                    onText?(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        onText?(text)
                    }
                @unknown default:
                    break
                }
            }
        } catch {
            await shutdown(error: error)
        }
    }
    
    private func scheduleReconnect() {
        guard reconnectTask == nil else { return }
        let delay = reconnectDelay
        reconnectDelay = min(reconnectDelay * 2, maxReconnectDelay)
        
        reconnectTask = Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(for: .seconds(delay))
            onConnect?()
            await self.cancelReconnect()
        }
    }
    
    // MARK: - Control methods
    
    private func makeSocket() {
        socket = session.webSocketTask(with: request)
        socket?.resume()
    }
    
    private func listen() {
        guard receiveTask == nil else { return }
        receiveTask = Task { await receiveLoop() }
        onConnect?()
    }
    
    private func cancelSocket() {
        socket?.cancel(with: .goingAway, reason: nil)
        socket = nil
    }
    
    private func cancelReceive() {
        receiveTask?.cancel()
        receiveTask = nil
    }
    
    private func cancelPing() {
        pingTask?.cancel()
        pingTask = nil
    }
    
    private func cancelReconnect() {
        reconnectTask?.cancel()
        reconnectTask = nil
    }
    
    private func resetReconnectDelay() {
        if reconnectDelay > 1 {
            reconnectDelay = 1
        }
    }
    
    // MARK: - Ping
    
    private func pingLoop() async {
        do {
            guard let socket else { throw URLError(.notConnectedToInternet) }
            for try await _ in pingStream(socket: socket, pingInterval: pingInterval) {
                listen()
                resetReconnectDelay()
            }
        } catch {
            await shutdown(error: error)
        }
    }
    
    private func pingStream(
        socket: URLSessionWebSocketTask,
        pingInterval: TimeInterval
    ) -> AsyncThrowingStream<Void, Error> {
        AsyncThrowingStream { continuation in
            @Sendable func sendNextPing() {
                guard !Task.isCancelled else {
                    continuation.finish()
                    return
                }

                socket.sendPing { error in
                    if let error {
                        continuation.finish(throwing: error)
                    } else {
                        continuation.yield(())
                        Task {
                            try await Task.sleep(for: .seconds(pingInterval))
                            sendNextPing()
                        }
                    }
                }
            }
            sendNextPing()
        }
    }
}
