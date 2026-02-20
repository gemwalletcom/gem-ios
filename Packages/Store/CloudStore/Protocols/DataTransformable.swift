// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public protocol DataTransformable: Sendable {
    func transform(_ data: Data) throws -> Data
    func restore(_ data: Data) throws -> Data
}
