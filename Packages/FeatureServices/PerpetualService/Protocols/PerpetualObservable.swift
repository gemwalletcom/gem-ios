// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public protocol PerpetualObservable<Subscription>: Actor {
    associatedtype Subscription: Encodable & Sendable
    var chartService: any ChartStreamable { get }
    func connect(for wallet: Wallet) async
    func disconnect() async
    func subscribe(_ subscription: Subscription) async throws
    func unsubscribe(_ subscription: Subscription) async throws
}
