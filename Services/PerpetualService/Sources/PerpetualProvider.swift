// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public protocol PerpetualProvidable: Sendable {
    func getPositions(wallet: Wallet) async throws -> [PerpetualPosition]
    func getMarkets() async throws -> [Perpetual]
}
