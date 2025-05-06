// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
@preconcurrency import WalletConnectRelay

// TODO: - remove preconcurrency, once walletconnect will be migrated to swift6
// URLSessionWebSocketTask - use async await instead of closure, once WC will be migrated to swift6

public final class NativeWebSocketClient: WebSocketConnecting, @unchecked Sendable {
    public var isConnected: Bool { io.sync { _isConnected } }
    public var onConnect: (() -> Void)?
    public var onDisconnect: ((Error?) -> Void)?
    public var onText: ((String) -> Void)?
    public var request: URLRequest

    private var _isConnected = false
    private let session: URLSession
    private let io = DispatchQueue(label: "NativeWebSocketClient")
    private var socket: URLSessionWebSocketTask?

    public init(request: URLRequest, session: URLSession = .shared) {
        self.request = request
        self.session = session
    }

    public func connect() {
        io.async { @Sendable [weak self] in
            guard let self else { return }
            let task = self.session.webSocketTask(with: self.request)
            self.socket = task
            task.resume()
            self._isConnected = true
            Task { @MainActor in self.onConnect?() }
            self.receiveNext()
        }
    }

    public func disconnect() {
        io.async { @Sendable [weak self] in
            guard let self, let socket = self.socket else { return }
            socket.cancel(with: .goingAway, reason: nil)
            self.socket = nil
            self._isConnected = false
            Task { @MainActor in self.onDisconnect?(nil) }
        }
    }

    public func write(string: String, completion: (() -> Void)? = nil) {
        io.async { [weak self] in
            guard let self,
                  let socket = self.socket else { return }

            socket.send(.string(string)) { [weak self] error in
                self?.io.async { [weak self] in
                    guard let self else { return }

                    if let error {
                        self._isConnected = false
                        if let onDisconnect = self.onDisconnect {
                            Task { @MainActor in onDisconnect(error) }
                        }
                    } else {
                        // Fire completion on the main thread
                        Task { @MainActor in completion?() }
                    }
                }
            }
        }
    }

    private func receiveNext() {
        guard let socket = socket else { return }
        socket.receive { @Sendable [weak self] result in
            guard let self else { return }
            switch result {
            case .success(.string(let text)):
                Task { @MainActor in self.onText?(text) }
                self.receiveNext()
            case .success(.data(let data)):
                if let text = String(data: data, encoding: .utf8) {
                    Task { @MainActor in self.onText?(text) }
                }
                self.receiveNext()
            case .failure(let error):
                self.io.async {
                    self._isConnected = false
                    Task { @MainActor in self.onDisconnect?(error) }
                }
            @unknown default:
                break
            }
        }
    }
}
