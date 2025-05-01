// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
@preconcurrency import WalletConnectRelay

private struct WSConnectingCompletionBox: @unchecked Sendable {
    let callback: (() -> Void)?

    func call() {
        callback?()
    }
}

// TODO: - remove preconcurrency, once walletconnect will be migrated to swift6
// URLSessionWebSocketTask - use async await instead of closure, once WC will be migrated to swift6

public final class NativeWebSocketClient: WebSocketConnecting, @unchecked Sendable {
    public private(set) var isConnected = false
    public var onConnect: (() -> Void)?
    public var onDisconnect: ((Error?) -> Void)?
    public var onText: ((String) -> Void)?
    public var request: URLRequest

    private let session: URLSession
    private var socket: URLSessionWebSocketTask?

    public init(request: URLRequest, session: URLSession = .shared) {
        self.request = request
        self.session = session
    }

    public func connect() {
        socket = session.webSocketTask(with: request)
        socket?.resume()
        isConnected = true
        onConnect?()
        receiveNext()
    }

    public func disconnect() {
        socket?.cancel(with: .goingAway, reason: nil)
        isConnected = false
        onDisconnect?(nil)
    }

    public func write(string: String, completion: (() -> Void)? = nil) {
        // Wrap the non-Sendable closure
        let box = WSConnectingCompletionBox(callback: completion)

        socket?.send(.string(string)) { [weak self] error in
            if let error {
                self?.isConnected = false
                self?.onDisconnect?(error)
            } else {
                box.call()
            }
        }
    }

    private func receiveNext() {
        socket?.receive { @Sendable [weak self] result in
            guard let self else { return }
            switch result {
            case .success(.string(let text)):
                self.onText?(text)
                self.receiveNext()
            case .success(.data(let data)):
                if let text = String(data: data, encoding: .utf8) {
                    self.onText?(text)
                }
                self.receiveNext()
            case .failure(let error):
                self.isConnected = false
                self.onDisconnect?(error)
            @unknown default:
                break
            }
        }
    }
}
