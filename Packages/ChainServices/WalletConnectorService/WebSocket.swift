// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import WalletConnectRelay

final class WebSocket: NSObject, @unchecked Sendable {

    @Locked var request: URLRequest
    @Locked private(set) var isConnected: Bool = false
    @Locked var onConnect: (() -> Void)?
    @Locked var onDisconnect: ((Error?) -> Void)?
    @Locked var onText: ((String) -> Void)?

    @Locked private var task: URLSessionWebSocketTask?
    @Locked private var session: URLSession?

    private let delegateQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    init(request: URLRequest) {
        self._request = Locked(wrappedValue: request)
        super.init()
    }

    deinit {
        closeConnection(.goingAway)
    }

    private func receiveMessage() {
        task?.receive { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self.onText?(text)
                case .data(let data):
                    if let text = try? data.encodeString() {
                        self.onText?(text)
                    }
                @unknown default:
                    break
                }
                self.receiveMessage()
            case .failure:
                break
            }
        }
    }
    
    private func closeConnection(_ closeCode: URLSessionWebSocketTask.CloseCode) {
        task?.cancel(with: closeCode, reason: nil)
        session?.invalidateAndCancel()
    }
    
    private func handleDisconnect(error: Error?) {
        guard isConnected else { return }
        isConnected = false
        onDisconnect?(error)
    }

    private func isCurrentTask(_ urlSessionTask: URLSessionTask) -> Bool {
        task === urlSessionTask
    }
}

// MARK: - WebSocketConnecting

extension WebSocket: WebSocketConnecting {
    func connect() {
        closeConnection(.goingAway)
        session = URLSession(configuration: .default, delegate: self, delegateQueue: delegateQueue)
        task = session?.webSocketTask(with: request)
        task?.resume()
        receiveMessage()
    }

    func disconnect() {
        closeConnection(.normalClosure)
    }

    func write(string: String, completion: (() -> Void)?) {
        guard let task else {
            completion?()
            return
        }
        let sendableCompletion = UncheckedSendable(value: completion)
        task.send(.string(string)) { _ in
            sendableCompletion.value?()
        }
    }
}

// MARK: - URLSessionWebSocketDelegate

extension WebSocket: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        guard isCurrentTask(webSocketTask) else { return }
        isConnected = true
        onConnect?()
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        guard isCurrentTask(webSocketTask) else { return }
        handleDisconnect(error: nil)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard isCurrentTask(task) else { return }
        handleDisconnect(error: error)
    }
}
