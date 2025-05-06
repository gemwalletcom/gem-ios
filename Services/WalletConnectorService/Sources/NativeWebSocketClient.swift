// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
@preconcurrency import WalletConnectRelay

// TODO: - remove preconcurrency, once walletconnect will be migrated to swift6
// URLSessionWebSocketTask - use async await instead of closure, once WC will be migrated to swift6
// Wrapper that lets us move any value across @Sendable boundaries.
private struct UnsafeSendable<T>: @unchecked Sendable {
    let value: T

    init(_ value: T) { self.value = value }
}

public final class NativeWebSocketClient: WebSocketConnecting, @unchecked Sendable {
    public var onConnect: (() -> Void)?
    public var onDisconnect: ((Error?) -> Void)?
    public var onText: ((String) -> Void)?
    public var request: URLRequest

    private let session: URLSession
    private let work = DispatchQueue(label: "NativeWebSocketClient")
    private var socket: URLSessionWebSocketTask?
    private var _isConnected = false

    public var isConnected: Bool {
        var value = false
        work.sync { value = _isConnected }
        return value
    }

    public init(request: URLRequest, session: URLSession = .shared) {
        self.request = request
        self.session = session
    }

    public func connect() {
        work.async { [weak self] in self?._connect() }
    }

    public func disconnect() {
        work.async { [weak self] in self?._disconnect() }
    }

    public func write(string: String, completion: (() -> Void)? = nil) {
        // Wrap optional callback to sendable box
        let boxed = completion.map(UnsafeSendable.init)

        // capture only the box sendable closure
        work.async { [weak self] in
            self?._write(string, boxedCompletion: boxed)
        }
    }
}

// MARK: - Private

extension NativeWebSocketClient {
    private func _connect() {
        guard socket == nil else { return }

        let task = session.webSocketTask(with: request)
        socket  = task
        _isConnected = true

        task.resume()
        callOnMain(onConnect)
        receiveNext()
    }

    private func _disconnect(error: Error? = nil) {
        socket?.cancel(with: .goingAway, reason: nil)
        socket = nil
        _isConnected = false
        callOnMain(onDisconnect, error)
    }

    private func _write(
        _ text: String,
        boxedCompletion: UnsafeSendable<() -> Void>?
    ) {
        guard let socket else { return }

        socket.send(.string(text)) { [weak self] error in
            guard let self else { return }
            self.work.async {
                if let error {
                    self._isConnected = false
                    self.callOnMain(self.onDisconnect, error)
                } else if let boxedCompletion {
                    self.callOnMain(boxedCompletion.value)
                }
            }
        }
    }

    private func receiveNext() {
        guard let socket else { return }

        socket.receive { [weak self] result in
            guard let self else { return }
            self.work.async {
                switch result {
                case .success(.string(let txt)):
                    self.callOnMain(self.onText, txt)
                    self.receiveNext()
                case .success(.data(let data)):
                    if let txt = String(data: data, encoding: .utf8) {
                        self.callOnMain(self.onText, txt)
                    }
                    self.receiveNext()
                case .failure(let err):
                    self._disconnect(error: err)
                @unknown default:
                    break
                }
            }
        }
    }

    private func callOnMain(_ closure: (() -> Void)?) {
        guard let closure else { return }
        let boxed = UnsafeSendable(closure)
        DispatchQueue.main.async { boxed.value() }
    }

    private func callOnMain(_ closure: ((Error?) -> Void)?, _ error: Error?) {
        guard let closure else { return }
        let boxed = UnsafeSendable(closure)
        DispatchQueue.main.async { boxed.value(error) }
    }

    private func callOnMain(_ closure: ((String) -> Void)?, _ text: String) {
        guard let closure else { return }
        let boxed = UnsafeSendable(closure)
        DispatchQueue.main.async { boxed.value(text) }
    }
}
