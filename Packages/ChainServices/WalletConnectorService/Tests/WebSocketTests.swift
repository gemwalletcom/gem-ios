// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
@testable import WalletConnectorService

struct WebSocketTests {

    @Test
    func initialState() {
        let socket = WebSocket(request: URLRequest(url: URL(string: "wss://example.com")!))

        #expect(socket.isConnected == false)
        #expect(socket.onConnect == nil)
        #expect(socket.onDisconnect == nil)
        #expect(socket.onText == nil)
    }

    @Test
    func writeWithoutConnectionCallsCompletionImmediately() async {
        let socket = WebSocket(request: URLRequest(url: URL(string: "wss://example.com")!))

        await confirmation { confirm in
            socket.write(string: "test") {
                confirm()
            }
        }
    }

    // MARK: - Stress Tests

    @Test
    func stressTestConcurrentPropertyAccess() async {
        let socket = WebSocket(request: URLRequest(url: URL(string: "wss://example.com")!))
        let iterations = 1000

        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                for i in 0..<iterations {
                    socket.request = URLRequest(url: URL(string: "wss://test\(i).com")!)
                }
            }

            group.addTask {
                for _ in 0..<iterations {
                    _ = socket.request
                    _ = socket.isConnected
                }
            }

            group.addTask {
                for _ in 0..<iterations {
                    socket.onConnect = { }
                    socket.onDisconnect = { _ in }
                    socket.onText = { _ in }
                }
            }
        }
    }

    @Test
    func stressTestConcurrentWrites() async {
        let socket = WebSocket(request: URLRequest(url: URL(string: "wss://example.com")!))
        let iterations = 100

        await confirmation(expectedCount: iterations) { confirm in
            await withTaskGroup(of: Void.self) { group in
                for i in 0..<iterations {
                    group.addTask {
                        socket.write(string: "message\(i)") {
                            confirm()
                        }
                    }
                }
            }
        }
    }

    @Test
    func stressTestConcurrentConnectDisconnect() async {
        let socket = WebSocket(request: URLRequest(url: URL(string: "wss://example.com")!))
        let iterations = 50

        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                for _ in 0..<iterations {
                    socket.connect()
                }
            }

            group.addTask {
                for _ in 0..<iterations {
                    socket.disconnect()
                }
            }

            group.addTask {
                for _ in 0..<iterations {
                    _ = socket.isConnected
                }
            }
        }
    }
}
