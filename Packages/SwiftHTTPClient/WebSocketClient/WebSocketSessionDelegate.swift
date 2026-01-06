// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

final class WebSocketSessionDelegate: NSObject, URLSessionWebSocketDelegate, Sendable {

    private let didOpen: @Sendable () -> Void
    private let didClose: @Sendable (URLSessionWebSocketTask.CloseCode, Data?) -> Void

    init(
        didOpen: @escaping @Sendable () -> Void,
        didClose: @escaping @Sendable (URLSessionWebSocketTask.CloseCode, Data?) -> Void
    ) {
        self.didOpen = didOpen
        self.didClose = didClose
    }

    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        didOpen()
    }

    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        didClose(closeCode, reason)
    }
}
